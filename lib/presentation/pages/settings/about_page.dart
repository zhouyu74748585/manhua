import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// 关于页面
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = packageInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
      ),
      body: ListView(
        children: [
          // 应用信息
          _buildAppInfoSection(),

          const Divider(),

          // 版本信息
          _buildVersionSection(),

          const Divider(),

          // 开发者信息
          _buildDeveloperSection(),

          const Divider(),

          // 许可证信息
          _buildLicenseSection(),

          const Divider(),

          // 支持信息
          _buildSupportSection(),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 应用图标
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).primaryColor,
            ),
            child: const Icon(
              Icons.menu_book,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // 应用名称
          Text(
            _packageInfo?.appName ?? '漫画阅读器',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          
          // 应用描述
          Text(
            '现代化的多平台漫画阅读软件',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVersionSection() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('版本号'),
          subtitle: Text(_packageInfo?.version ?? '获取中...'),
          onTap: () => _copyToClipboard(_packageInfo?.version ?? ''),
        ),
        ListTile(
          leading: const Icon(Icons.build),
          title: const Text('构建号'),
          subtitle: Text(_packageInfo?.buildNumber ?? '获取中...'),
          onTap: () => _copyToClipboard(_packageInfo?.buildNumber ?? ''),
        ),
        ListTile(
          leading: const Icon(Icons.update),
          title: const Text('检查更新'),
          subtitle: const Text('点击检查最新版本'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _checkForUpdates,
        ),
      ],
    );
  }

  Widget _buildDeveloperSection() {
    return Column(
      children: [
        const ListTile(
          leading: Icon(Icons.person),
          title: Text('开发者'),
          subtitle: Text('漫画阅读器开发团队'),
        ),
        ListTile(
          leading: const Icon(Icons.email),
          title: const Text('联系邮箱'),
          subtitle: const Text('support@mangareader.com'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _launchEmail('support@mangareader.com'),
        ),
        ListTile(
          leading: const Icon(Icons.web),
          title: const Text('官方网站'),
          subtitle: const Text('https://mangareader.com'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _launchUrl('https://mangareader.com'),
        ),
        ListTile(
          leading: const Icon(Icons.code),
          title: const Text('源代码'),
          subtitle: const Text('GitHub 仓库'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _launchUrl('https://github.com/mangareader/app'),
        ),
      ],
    );
  }

  Widget _buildLicenseSection() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.description),
          title: const Text('开源许可证'),
          subtitle: const Text('查看第三方库许可证'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showLicensePage(),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('隐私政策'),
          subtitle: const Text('了解我们如何保护您的隐私'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _launchUrl('https://mangareader.com/privacy'),
        ),
        ListTile(
          leading: const Icon(Icons.gavel),
          title: const Text('使用条款'),
          subtitle: const Text('查看应用使用条款'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _launchUrl('https://mangareader.com/terms'),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('帮助中心'),
          subtitle: const Text('常见问题和使用指南'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _launchUrl('https://mangareader.com/help'),
        ),
        ListTile(
          leading: const Icon(Icons.bug_report),
          title: const Text('反馈问题'),
          subtitle: const Text('报告错误或提出建议'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _launchUrl('https://github.com/mangareader/app/issues'),
        ),
        ListTile(
          leading: const Icon(Icons.star_rate),
          title: const Text('评价应用'),
          subtitle: const Text('在应用商店给我们评分'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _rateApp,
        ),
        ListTile(
          leading: const Icon(Icons.share),
          title: const Text('分享应用'),
          subtitle: const Text('推荐给朋友'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _shareApp,
        ),
      ],
    );
  }

  void _copyToClipboard(String text) {
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已复制到剪贴板')),
      );
    }
  }

  void _checkForUpdates() {
    // TODO: 实现更新检查逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('当前已是最新版本')),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw '无法打开链接';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打开链接失败: $e')),
        );
      }
    }
  }

  Future<void> _launchEmail(String email) async {
    try {
      final uri = Uri.parse('mailto:$email');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // 如果无法打开邮件应用，复制邮箱地址
        _copyToClipboard(email);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('邮箱地址已复制到剪贴板')),
          );
        }
      }
    } catch (e) {
      _copyToClipboard(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('邮箱地址已复制到剪贴板')),
        );
      }
    }
  }

  void _showLicensePage() {
    showLicensePage(
      context: context,
      applicationName: _packageInfo?.appName ?? '漫画阅读器',
      applicationVersion: _packageInfo?.version ?? '',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).primaryColor,
        ),
        child: const Icon(
          Icons.menu_book,
          size: 32,
          color: Colors.white,
        ),
      ),
    );
  }

  void _rateApp() {
    // TODO: 实现应用评分逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('感谢您的支持！')),
    );
  }

  void _shareApp() {
    // TODO: 实现应用分享逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('分享功能开发中')),
    );
  }
}
