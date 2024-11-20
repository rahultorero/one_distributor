import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class DashBoardContent extends StatelessWidget {
  const DashBoardContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth > 600;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 100,left: 24,right: 24,bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),

                _buildQuickStats(isTablet),
                const SizedBox(height: 24),
                _buildRevenueSection(isTablet),
                const SizedBox(height: 24),
                if (isTablet)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildOrdersTable()),
                      const SizedBox(width: 24),
                      Expanded(child: _buildActiveRetailers()),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildOrdersTable(),
                      const SizedBox(height: 24),
                      _buildActiveRetailers(),
                    ],
                  ),
                const SizedBox(height: 24),
                _buildProductPerformance(isTablet),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductPerformance(bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Product Performance',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download),
                label: const Text('Export'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text('Product')),
                DataColumn(label: Text('Sales')),
                DataColumn(label: Text('Revenue')),
                DataColumn(label: Text('Growth')),
                DataColumn(label: Text('Stock')),
                DataColumn(label: Text('Status')),
              ],
              rows: [
                _buildProductRow(
                  'iPhone 13 Pro',
                  '842',
                  '₹84.2L',
                  '+12.4%',
                  '124',
                  'In Stock',
                ),
                _buildProductRow(
                  'Samsung S22',
                  '634',
                  '₹63.4L',
                  '+8.7%',
                  '82',
                  'Low Stock',
                ),
                _buildProductRow(
                  'OnePlus 10',
                  '542',
                  '₹54.2L',
                  '-2.4%',
                  '0',
                  'Out of Stock',
                ),
                _buildProductRow(
                  'Google Pixel 7',
                  '421',
                  '₹42.1L',
                  '+5.6%',
                  '45',
                  'In Stock',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 1000,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = [
                            'iPhone',
                            'Samsung',
                            'OnePlus',
                            'Pixel'
                          ];
                          if (value.toInt() < titles.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                titles[value.toInt()],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 200,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[200],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _createBarGroup(0, 842),
                    _createBarGroup(1, 634),
                    _createBarGroup(2, 542),
                    _createBarGroup(3, 421),
                    _createBarGroup(4, 1000),

                  ],
                ),
              ),
            ),
          ],

      ),
    );
  }

  DataRow _buildProductRow(
      String product,
      String sales,
      String revenue,
      String growth,
      String stock,
      String status,
      ) {
    return DataRow(
      cells: [
        DataCell(Text(product)),
        DataCell(Text(sales)),
        DataCell(Text(revenue)),
        DataCell(
          Text(
            growth,
            style: TextStyle(
              color: growth.startsWith('+') ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        DataCell(Text(stock)),
        DataCell(_buildStockStatus(status)),
      ],
    );
  }

  Widget _buildStockStatus(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'in stock':
        color = Colors.green;
        break;
      case 'low stock':
        color = Colors.orange;
        break;
      case 'out of stock':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  BarChartGroupData _createBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.blue[700],
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }


  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Overview',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome back, Admin',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(bool isTablet) {
    final stats = [
      _StatItem(
        icon: Icons.shopping_cart,
        label: 'Total Orders',
        value: '2,543',
        growth: '+12.5%',
        color: Colors.blue,
      ),
      _StatItem(
        icon: Icons.person,
        label: 'Active Users',
        value: '1,234',
        growth: '+8.2%',
        color: Colors.green,
      ),
      _StatItem(
        icon: Icons.store,
        label: 'Active Retailers',
        value: '487',
        growth: '+5.7%',
        color: Colors.purple,
      ),
      _StatItem(
        icon: Icons.pending_actions,
        label: 'Outstanding',
        value: '₹45.2K',
        growth: '-2.4%',
        color: Colors.orange,
        isNegative: true,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isTablet ? 1.14 : 1.05,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: stat.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(stat.icon, color: stat.color),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: stat.isNegative
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      stat.growth,
                      style: TextStyle(
                        color: stat.isNegative ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                stat.value,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stat.label,
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRevenueSection(bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Revenue Overview',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildPeriodSelector(),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200],
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        const labels = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun'
                        ];
                        if (value.toInt() < labels.length) {
                          return Text(
                            labels[value.toInt()],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}K',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(1, 4),
                      FlSpot(2, 3.5),
                      FlSpot(3, 5),
                      FlSpot(4, 4),
                      FlSpot(5, 6),
                    ],
                    isCurved: true,
                    color: Colors.blue[700],
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue[700]!.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            'Last 6 months',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 3),
          Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey[700],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTable() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Orders',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Order ID')),
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Amount')),
              ],
              rows: [
                _buildOrderRow('12345', 'John Doe', 'Delivered', '₹2,500'),
                _buildOrderRow('12346', 'Jane Smith', 'Pending', '₹1,800'),
                _buildOrderRow('12347', 'Mike Johnson', 'Processing', '₹3,200'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildOrderRow(String orderId,
      String customer,
      String status,
      String amount,) {
    return DataRow(
      cells: [
        DataCell(Text(orderId)),
        DataCell(Text(customer)),
        DataCell(_buildStatusChip(status)),
        DataCell(Text(amount)),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'delivered':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'processing':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActiveRetailers() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Retailers',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 190,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: 35,
                    title: '35%',
                    color: Colors.blue[700],
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: 25,
                    title: '25%',
                    color: Colors.green[600],
                    radius: 45,
                  ),
                  PieChartSectionData(
                    value: 20,
                    title: '20%',
                    color: Colors.orange[400],
                    radius: 40,
                  ),
                  PieChartSectionData(
                    value: 20,
                    title: '20%',
                    color: Colors.purple[300],
                    radius: 35,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final String growth;
  final Color color;
  final bool isNegative;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.growth,
    required this.color,
    this.isNegative = false,
  });
}