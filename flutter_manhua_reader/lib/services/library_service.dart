import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/library.dart';
import '../data/repositories/library_repository.dart';

part 'library_service.g.dart';

@riverpod
LibraryService libraryService(Ref ref) {
  return LibraryService(ref.read(libraryRepositoryProvider));
}

class LibraryService {
  final LibraryRepository _repository;
  
  LibraryService(this._repository);
  
  Future<List<MangaLibrary>> getAllLibraries() async {
    return await _repository.getAllLibraries();
  }
  
  Future<MangaLibrary?> getLibraryById(String id) async {
    return await _repository.getLibraryById(id);
  }
  
  Future<void> addLibrary(MangaLibrary library) async {
    // 验证库路径
    await _validateLibraryPath(library.path, library.type);
    
    // 生成唯一ID
    final libraryWithId = library.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
    );
    
    await _repository.addLibrary(libraryWithId);
  }
  
  Future<void> updateLibrary(MangaLibrary library) async {
    // 如果路径发生变化，需要重新验证
    final existingLibrary = await _repository.getLibraryById(library.id);
    if (existingLibrary != null && existingLibrary.path != library.path) {
      await _validateLibraryPath(library.path, library.type);
    }
    
    await _repository.updateLibrary(library);
  }
  
  Future<void> deleteLibrary(String id) async {
    await _repository.deleteLibrary(id);
  }
  
  Future<void> scanLibrary(String id) async {
    final library = await _repository.getLibraryById(id);
    if (library == null || !library.isEnabled) {
      throw Exception('库不存在或已禁用');
    }
    
    try {
      // 根据库类型执行不同的扫描逻辑
      int mangaCount = 0;
      switch (library.type) {
        case LibraryType.local:
          mangaCount = await _scanLocalLibrary(library);
          break;
        case LibraryType.network:
          mangaCount = await _scanNetworkLibrary(library);
          break;
        case LibraryType.cloud:
          mangaCount = await _scanCloudLibrary(library);
          break;
      }
      
      // 更新扫描时间和漫画数量
      final updatedLibrary = library.copyWith(
        lastScanAt: DateTime.now(),
        mangaCount: mangaCount,
      );
      
      await _repository.updateLibrary(updatedLibrary);
    } catch (e) {
      throw Exception('扫描库失败: $e');
    }
  }
  
  Future<void> scanAllLibraries() async {
    final libraries = await _repository.getAllLibraries();
    final enabledLibraries = libraries.where((lib) => lib.isEnabled);
    
    for (final library in enabledLibraries) {
      try {
        await scanLibrary(library.id);
      } catch (e) {
        // 记录错误但继续扫描其他库
        print('扫描库 ${library.name} 失败: $e');
      }
    }
  }
  
  Future<bool> validateLibraryPath(String path, LibraryType type) async {
    try {
      await _validateLibraryPath(path, type);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> _validateLibraryPath(String path, LibraryType type) async {
    switch (type) {
      case LibraryType.local:
        await _validateLocalPath(path);
        break;
      case LibraryType.network:
        await _validateNetworkPath(path);
        break;
      case LibraryType.cloud:
        await _validateCloudPath(path);
        break;
    }
  }
  
  Future<void> _validateLocalPath(String path) async {
    if (path.isEmpty) {
      throw Exception('路径不能为空');
    }
    
    try {
      final directory = Directory(path);
      
      // 检查路径是否存在
      if (!await directory.exists()) {
        throw Exception('路径不存在: $path');
      }
      
      // 检查是否为目录
      final stat = await directory.stat();
      if (stat.type != FileSystemEntityType.directory) {
        throw Exception('指定路径不是一个目录: $path');
      }
      
      // 检查读取权限（尝试列出目录内容）
      try {
        await directory.list().take(1).toList();
      } catch (e) {
        throw Exception('没有读取权限: $path');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('路径验证失败: $e');
    }
  }
  
  Future<void> _validateNetworkPath(String path) async {
    if (path.isEmpty) {
      throw Exception('网络路径不能为空');
    }
    
    try {
      // 检查是否为有效的网络路径格式
      final uri = Uri.tryParse(path);
      if (uri == null || (!uri.hasScheme || !['http', 'https', 'ftp', 'smb'].contains(uri.scheme.toLowerCase()))) {
        throw Exception('无效的网络路径格式，支持的协议: http, https, ftp, smb');
      }
      
      // 对于HTTP/HTTPS路径，尝试发送HEAD请求验证可访问性
      if (['http', 'https'].contains(uri.scheme.toLowerCase())) {
        final client = HttpClient();
        try {
          final request = await client.openUrl('HEAD', uri);
          request.headers.set('User-Agent', 'MangaReader/1.0');
          final response = await request.close();
          
          if (response.statusCode >= 400) {
            throw Exception('网络路径不可访问，状态码: ${response.statusCode}');
          }
        } finally {
          client.close();
        }
      }
      
      // 对于其他协议，暂时只验证格式
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('网络路径验证失败: $e');
    }
  }
  
  Future<void> _validateCloudPath(String path) async {
    if (path.isEmpty) {
      throw Exception('云端路径不能为空');
    }
    
    try {
      // 检查是否为有效的云端路径格式
      final uri = Uri.tryParse(path);
      if (uri == null) {
        throw Exception('无效的云端路径格式');
      }
      
      // 检查支持的云端服务
      final supportedServices = {
        'drive.google.com': 'Google Drive',
        'onedrive.live.com': 'OneDrive',
        'dropbox.com': 'Dropbox',
        's3.amazonaws.com': 'Amazon S3',
        'api.box.com': 'Box',
      };
      
      bool isSupported = false;
      String? serviceName;
      
      for (final entry in supportedServices.entries) {
        if (uri.host.contains(entry.key) || path.toLowerCase().contains(entry.key)) {
          isSupported = true;
          serviceName = entry.value;
          break;
        }
      }
      
      if (!isSupported) {
        final supportedList = supportedServices.values.join(', ');
        throw Exception('不支持的云端服务，支持的服务: $supportedList');
      }
      
      // 对于云端路径，需要检查是否包含必要的认证信息或API密钥
      // 这里只做基本格式验证，实际的API验证需要在扫描时进行
      if (!uri.hasScheme || !['http', 'https'].contains(uri.scheme.toLowerCase())) {
        throw Exception('云端路径必须使用 HTTPS 协议');
      }
      
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('云端路径验证失败: $e');
    }
  }
  
  Future<int> _scanLocalLibrary(MangaLibrary library) async {
    try {
      final directory = Directory(library.path);
      if (!await directory.exists()) {
        throw Exception('目录不存在: ${library.path}');
      }
      
      // 支持的漫画文件格式
      final supportedExtensions = {'.cbz', '.cbr', '.zip', '.rar', '.pdf', '.epub'};
      
      int mangaCount = 0;
      
      // 递归扫描目录
      await for (final entity in directory.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final extension = entity.path.toLowerCase().split('.').last;
          if (supportedExtensions.contains('.$extension')) {
            // 这里可以添加更详细的漫画文件处理逻辑
            // 比如提取元数据、生成缩略图等
            mangaCount++;
            
            // 添加一些延迟以避免过度占用系统资源
            if (mangaCount % 10 == 0) {
              await Future.delayed(const Duration(milliseconds: 10));
            }
          }
        }
      }
      
      return mangaCount;
    } catch (e) {
      throw Exception('扫描本地库失败: $e');
    }
  }
  
  Future<int> _scanNetworkLibrary(MangaLibrary library) async {
    try {
      final uri = Uri.parse(library.path);
      
      if (['http', 'https'].contains(uri.scheme.toLowerCase())) {
        // HTTP/HTTPS 网络扫描
        return await _scanHttpLibrary(uri);
      } else if (uri.scheme.toLowerCase() == 'ftp') {
        // FTP 扫描（暂时返回0，需要FTP客户端库支持）
        throw Exception('FTP 协议暂不支持，请使用 HTTP/HTTPS');
      } else if (uri.scheme.toLowerCase() == 'smb') {
        // SMB 扫描（暂时返回0，需要SMB客户端库支持）
        throw Exception('SMB 协议暂不支持，请使用 HTTP/HTTPS');
      } else {
        throw Exception('不支持的网络协议: ${uri.scheme}');
      }
    } catch (e) {
      throw Exception('扫描网络库失败: $e');
    }
  }
  
  Future<int> _scanHttpLibrary(Uri uri) async {
    final client = HttpClient();
    try {
      // 发送GET请求获取目录列表
      final request = await client.getUrl(uri);
      request.headers.set('User-Agent', 'MangaReader/1.0');
      final response = await request.close();
      
      if (response.statusCode != 200) {
        throw Exception('HTTP请求失败，状态码: ${response.statusCode}');
      }
      
      // 读取响应内容
      final content = await response.transform(utf8.decoder).join();
      
      // 简单的HTML解析，查找漫画文件链接
      final supportedExtensions = {'.cbz', '.cbr', '.zip', '.rar', '.pdf', '.epub'};
      int mangaCount = 0;
      
      // 使用正则表达式查找文件链接
      final linkPattern = RegExp(r'href=["\']([^"\'>]+)["\']', caseSensitive: false);
      final matches = linkPattern.allMatches(content);
      
      for (final match in matches) {
        final link = match.group(1);
        if (link != null) {
          final extension = link.toLowerCase().split('.').last;
          if (supportedExtensions.contains('.$extension')) {
            mangaCount++;
          }
        }
      }
      
      return mangaCount;
    } finally {
      client.close();
    }
  }
  
  Future<int> _scanCloudLibrary(MangaLibrary library) async {
    try {
      final uri = Uri.parse(library.path);
      
      // 根据不同的云端服务提供商进行扫描
      if (uri.host.contains('drive.google.com')) {
        return await _scanGoogleDrive(uri);
      } else if (uri.host.contains('onedrive.live.com')) {
        return await _scanOneDrive(uri);
      } else if (uri.host.contains('dropbox.com')) {
        return await _scanDropbox(uri);
      } else if (uri.host.contains('s3.amazonaws.com')) {
        return await _scanAmazonS3(uri);
      } else {
        // 对于其他云端服务，尝试通用的HTTP扫描
        return await _scanHttpLibrary(uri);
      }
    } catch (e) {
      throw Exception('扫描云端库失败: $e');
    }
  }
  
  Future<int> _scanGoogleDrive(Uri uri) async {
    // Google Drive API 扫描
    // 注意：这需要 Google Drive API 密钥和认证
    throw Exception('Google Drive 扫描需要配置 API 密钥，请联系开发者');
  }
  
  Future<int> _scanOneDrive(Uri uri) async {
    // OneDrive API 扫描
    throw Exception('OneDrive 扫描需要配置 API 密钥，请联系开发者');
  }
  
  Future<int> _scanDropbox(Uri uri) async {
    // Dropbox API 扫描
    throw Exception('Dropbox 扫描需要配置 API 密钥，请联系开发者');
  }
  
  Future<int> _scanAmazonS3(Uri uri) async {
    // Amazon S3 API 扫描
    throw Exception('Amazon S3 扫描需要配置 AWS 凭证，请联系开发者');
  }
}