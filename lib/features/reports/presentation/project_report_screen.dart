import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mzansi_meds_reminder/core/utils/report_generator.dart';

/// Example screen showing how to generate and share the project report
/// This is a utility screen that can be added to your worker dashboard
class ProjectReportScreen extends StatefulWidget {
  const ProjectReportScreen({super.key});

  @override
  State<ProjectReportScreen> createState() => _ProjectReportScreenState();
}

class _ProjectReportScreenState extends State<ProjectReportScreen> {
  bool _isGenerating = false;
  String? _reportPath;
  String? _error;

  Future<void> _generateReport() async {
    setState(() {
      _isGenerating = true;
      _error = null;
    });

    try {
      final reportFile = await ReportGenerator.generateProjectReport();
      setState(() {
        _reportPath = reportFile.path;
        _isGenerating = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report generated: ${reportFile.path}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Error generating report: $e';
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_error ?? 'Error generating report'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _shareReport() async {
    if (_reportPath == null) return;

    try {
      await Share.shareXFiles(
        [XFile(_reportPath!)],
        subject: 'MedAdhere Project Report',
        text: 'Project Report for MedAdhere - Medication Adherence Tracking System',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Report'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MedAdhere Project Report',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Generate a comprehensive PDF report containing:',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 12),
                    ProjectReportItem(
                      icon: '📋',
                      title: 'Project Overview',
                      description: 'Title, team info, problem statement',
                    ),
                    SizedBox(height: 8),
                    ProjectReportItem(
                      icon: '✅',
                      title: 'Implemented Features',
                      description: 'Complete list of working features',
                    ),
                    SizedBox(height: 8),
                    ProjectReportItem(
                      icon: '🔄',
                      title: 'Pending Features',
                      description: 'M5 roadmap with priorities & timeline',
                    ),
                    SizedBox(height: 8),
                    ProjectReportItem(
                      icon: '🏗️',
                      title: 'System Design',
                      description: 'Architecture overview & tech stack',
                    ),
                    SizedBox(height: 8),
                    ProjectReportItem(
                      icon: '📊',
                      title: 'Evaluation & Results',
                      description: 'Testing methodology & improvements',
                    ),
                    SizedBox(height: 8),
                    ProjectReportItem(
                      icon: '⚠️',
                      title: 'Limitations & Risks',
                      description: 'Known issues & mitigation strategies',
                    ),
                    SizedBox(height: 8),
                    ProjectReportItem(
                      icon: '📚',
                      title: 'References',
                      description: 'Libraries, tools, and documentation',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
            if (_reportPath != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✅ Report Generated Successfully',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _reportPath!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateReport,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.file_download),
                label: Text(
                  _isGenerating ? 'Generating Report...' : 'Generate PDF Report',
                ),
              ),
            ),
            if (_reportPath != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _shareReport,
                  icon: const Icon(Icons.share),
                  label: const Text('Share Report'),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    ReportDetailRow(
                      label: 'Format',
                      value: 'PDF (A4)',
                    ),
                    SizedBox(height: 8),
                    ReportDetailRow(
                      label: 'Pages',
                      value: '7 pages',
                    ),
                    SizedBox(height: 8),
                    ReportDetailRow(
                      label: 'Content',
                      value: '8 sections + diagrams',
                    ),
                    SizedBox(height: 8),
                    ReportDetailRow(
                      label: 'Generated',
                      value: 'May 12, 2026',
                    ),
                    SizedBox(height: 8),
                    ReportDetailRow(
                      label: 'Version',
                      value: '1.0.0',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectReportItem extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const ProjectReportItem({
    required this.icon,
    required this.title,
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ReportDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const ReportDetailRow({
    required this.label,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
