import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';

class _ClassificationRow {
  final String target;
  final String model;
  final String testMetric;
  final String trainMetric;
  final String verdict;
  final bool good;

  const _ClassificationRow(this.target, this.model, this.testMetric,
      this.trainMetric, this.verdict, this.good);
}

// Table V (best model per target) with the matching train score from Table III.
const _rows = [
  _ClassificationRow('Source Airport', 'XGBoost', 'F1 = 0.688', 'F1 = 1.000',
      'Yes, strong', true),
  _ClassificationRow(
      'Airline', 'XGBoost', 'F1 = 0.260', 'F1 = 0.997', 'Weak', false),
  _ClassificationRow('Booking Source', 'XGBoost', 'F1 = 0.327', 'F1 = 0.998',
      'No, random', false),
  _ClassificationRow('Cabin Class', 'Logistic Reg.', 'F1 = 0.317',
      'F1 = 0.377', 'No, validated', false),
];

// Table III
const _trainTest = [
  ['Total Fare', 'Linear Reg.', 'R²=0.872', 'R²=0.883'],
  ['Total Fare', 'Random Forest', 'R²=0.984', 'R²=0.890'],
  ['Total Fare', 'XGBoost', 'R²=0.990', 'R²=0.884'],
  ['Class', 'Logistic Reg.', 'F1=0.377', 'F1=0.317'],
  ['Class', 'Random Forest', 'F1=1.000', 'F1=0.295'],
  ['Class', 'XGBoost', 'F1=0.993', 'F1=0.304'],
  ['Airline', 'Logistic Reg.', 'F1=0.139', 'F1=0.139'],
  ['Airline', 'Random Forest', 'F1=1.000', 'F1=0.191'],
  ['Airline', 'XGBoost', 'F1=0.997', 'F1=0.260'],
  ['Booking Src.', 'Logistic Reg.', 'F1=0.308', 'F1=0.278'],
  ['Booking Src.', 'Random Forest', 'F1=1.000', 'F1=0.298'],
  ['Booking Src.', 'XGBoost', 'F1=0.998', 'F1=0.327'],
  ['Source', 'Logistic Reg.', 'F1=0.106', 'F1=0.109'],
  ['Source', 'Random Forest', 'F1=1.000', 'F1=0.658'],
  ['Source', 'XGBoost', 'F1=1.000', 'F1=0.688'],
];

// Table IV
const _chiSquare = [
  ['Source', '18.18', '0.1986', 'Not significant'],
  ['Destination', '5.69', '0.9309', 'Not significant'],
  ['Airline', '5.35', '0.5000', 'Not significant'],
  ['Seasonality', '5.77', '0.4493', 'Not significant'],
  ['Booking Source', '1.46', '0.8336', 'Not significant'],
  ['Stopovers', '0.00', '1.0000', 'Not significant'],
];

// Table VI
const _comparison = [
  ['Tziridis et al. (2017)', 'Ensemble/kernel', 'Beat linear baseline',
      '1,814 flights'],
  ['Rajankar et al. (2019)', 'Random Forest', 'Best MAE/RMSE', 'Not specified'],
  ['Zhou et al. (2025)', 'Random Forest', 'Best accuracy', '300,153 flights'],
  ['IEEE study (2025)', 'Random Forest', 'R²=0.81', 'Not specified'],
  ['This study (2026)', 'Random Forest', 'R²=0.890, RMSE=1,300.04 BDT',
      '3,618 flights'],
];

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerCard(),
          const SizedBox(height: 20),
          _classificationTable(),
          const SizedBox(height: 20),
          _table(
            'Train vs test (Table III)',
            ['Target', 'Model', 'Train', 'Test'],
            _trainTest,
            note: 'Fare rows show R\u00b2; all other rows show macro-F1.',
          ),
          const SizedBox(height: 20),
          _table(
            'Chi-square: Class vs features (Table IV)',
            ['Feature', '\u03c7\u00b2', 'p-value', 'Result'],
            _chiSquare,
            note: 'No feature is significantly associated with Class '
                '(p > 0.05 in every case).',
          ),
          const SizedBox(height: 20),
          _table(
            'Comparison with other studies (Table VI)',
            ['Study', 'Best model', 'Key metric', 'Dataset'],
            _comparison,
          ),
          const SizedBox(height: 20),
          _keyFindingCard(),
        ],
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: const [
          Expanded(
            child: StatCard(
                label: 'Best fare model', value: 'Random Forest', dark: true),
          ),
          SizedBox(width: 12),
          Expanded(
            child: StatCard(
                label: 'Test R\u00b2',
                value: '0.890',
                valueColor: AppColors.amber,
                dark: true),
          ),
          SizedBox(width: 12),
          Expanded(
            child: StatCard(label: 'Records', value: '3,618', dark: true),
          ),
        ],
      ),
    );
  }

  Widget _classificationTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Best model per target (Table V)',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy)),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.navy),
                headingTextStyle: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                columns: const [
                  DataColumn(label: Text('Target')),
                  DataColumn(label: Text('Best model')),
                  DataColumn(label: Text('Test metric')),
                  DataColumn(label: Text('Train metric')),
                  DataColumn(label: Text('Predictable?')),
                ],
                rows: _rows
                    .map((r) => DataRow(cells: [
                          DataCell(Text(r.target,
                              style: const TextStyle(color: AppColors.grey))),
                          DataCell(Text(r.model,
                              style: const TextStyle(color: AppColors.grey))),
                          DataCell(Text(r.testMetric,
                              style: const TextStyle(color: AppColors.grey))),
                          DataCell(Text(r.trainMetric,
                              style: const TextStyle(color: AppColors.grey))),
                          DataCell(Text(
                            r.verdict,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: r.good ? AppColors.green : AppColors.red,
                            ),
                          )),
                        ]))
                    .toList(),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Total Fare: Random Forest, test R\u00b2 = 0.890, '
              'RMSE = 1,300.04 BDT, MAE = 1,061.34 BDT. On the weak targets '
              'the ensemble models score near-perfect on training data but '
              'near-random on test data, which means they memorised noise. '
              'Chi-square tests confirm this for Class (all p > 0.05).',
              style: TextStyle(
                  fontSize: 12.5,
                  fontStyle: FontStyle.italic,
                  color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _table(
    String title,
    List<String> cols,
    List<List<String>> rows, {
    String? note,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy)),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.navy),
                headingTextStyle: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                columns: cols.map((c) => DataColumn(label: Text(c))).toList(),
                rows: rows
                    .map((r) => DataRow(
                          cells: r
                              .map((c) => DataCell(Text(c,
                                  style:
                                      const TextStyle(color: AppColors.grey))))
                              .toList(),
                        ))
                    .toList(),
              ),
            ),
            if (note != null) ...[
              const SizedBox(height: 14),
              Text(note,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                      color: AppColors.grey)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _keyFindingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Key finding',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy)),
            const SizedBox(height: 10),
            const Text(
              'Attributes tied to route geometry or pricing tiers (Total Fare, '
              'Departure Airport) are strongly predictable. Attributes that '
              'reflect individual assignment or choice (Class, Airline, '
              'Booking Source) are not. This is supported two independent '
              'ways: train-test overfitting and chi-square independence '
              'testing.',
              style: TextStyle(
                  fontSize: 13.5, height: 1.5, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
