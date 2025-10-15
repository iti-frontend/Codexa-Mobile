import 'package:codexa_mobile/Ui/utils/theme/app_colors.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_home_tape_components.dart';
import 'package:codexa_mobile/Ui/utils/widgets/custom_section_title.dart';
import 'package:flutter/material.dart';

class CoursesTab extends StatefulWidget {
  const CoursesTab({super.key});

  @override
  State<CoursesTab> createState() => _CoursesTabState();
}

class _CoursesTabState extends State<CoursesTab> {
  // list of the progress main titles
  List<String> mainTitles = ['All', 'In Progress', 'Completed'];

  // list of the category titles
  List<String> categoryTitles = [
    'All',
    'Frontend',
    'Devops',
    'Data Structure',
    'OOP',
    'Machine Learning'
  ];

  final List<Map<String, dynamic>> courseCards = [
    {
      'categoryTitle': 'Web Development',
      'courseTitle': 'Mastering React.js',
      'percentage': 0.85, // 85%,
      'percentageByNumber': '85%'
    },
    {
      'categoryTitle': 'Mobile Development',
      'courseTitle': 'Flutter from Zero to Hero',
      'percentage': 0.65, // 65%
      'percentageByNumber': '65%'
    },
    {
      'categoryTitle': 'Data Science',
      'courseTitle': 'Python for Machine Learning',
      'percentage': 0.45, // 45%
      'percentageByNumber': '45%'
    },
    {
      'categoryTitle': 'UI/UX Design',
      'courseTitle': 'Design Thinking Basics',
      'percentage': 0.75, // 75%
      'percentageByNumber': '75%'
    },
    {
      'categoryTitle': 'Backend Development',
      'courseTitle': 'Node.js & MongoDB Masterclass',
      'percentage': 0.9, // 90%
      'percentageByNumber': '90%'
    },
  ];

  // to control main items
  int selectedMainIndex = 0;

  // to control category items
  int selectedCategoryIndex = 0;

  // main flag to control active or not
  bool isMainSelected = true;
  bool isCategorySelected = false;

  @override
  Widget build(BuildContext context) {
    // padding to adjust the container
    return Padding(
      padding: const EdgeInsets.all(20.0),
      // all widgets nested here
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // default is center and design tells us to be start
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20.0,
            ),
            // wrap for fixing and aligning our row widgets
            Wrap(
              spacing: 8, // horizontal space between items
              // list to generate items
              children: List.generate(mainTitles.length, (index) {
                bool isSelected = selectedMainIndex == index;
                return customSectionTitle(
                  backgroundColor: isSelected
                      ? AppColorsDark.accentBlue
                      : Colors.transparent,
                  textColor: isSelected
                      ? AppColorsDark.primaryText
                      : AppColorsDark.secondaryText,
                  context: context,
                  title: mainTitles[index],
                  isSelected: selectedMainIndex == index,
                  onPressed: () {
                    // here we change active index later on we might using provider
                    setState(() {
                      selectedMainIndex = index;
                    });
                  },
                );
              }),
            ),
            SizedBox(
              height: 30.0,
            ),
            Text(
              'Category',
              style: TextStyle(
                  color: AppColorsDark.primaryText,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20.0,
            ),
            Wrap(
              spacing: 4, // horizontal space between items
              runSpacing: 16, // vertical space between rows
              children: List.generate(categoryTitles.length, (index) {
                bool isSelected = selectedCategoryIndex == index;
                return customSectionTitle(
                  backgroundColor:
                      isSelected ? Color(0xff1e293b) : Colors.transparent,
                  textColor: isSelected
                      ? Color(0xff2563eb)
                      : AppColorsDark.secondaryText,
                  context: context,
                  title: categoryTitles[index],
                  isSelected: selectedCategoryIndex == index,
                  onPressed: () {
                    setState(() {
                      selectedCategoryIndex = index;
                    });
                  },
                );
              }),
            ),
            SizedBox(
              height: 30.0,
            ),
            Column(
              children: List.generate(courseCards.length, (index) {
                return DashboardCard(
                    haveBanner: false,
                    child: CourseProgressItem(
                        categoryTitle: courseCards[index]['categoryTitle'],
                        hasCategory: true,
                        categoryPercentage: courseCards[index]
                            ['percentageByNumber'],
                        title: courseCards[index]['courseTitle'],
                        progress: courseCards[index]['percentage'],
                        color: AppColorsDark.accentGreen));
              }),
            )
            // DashboardCard(
            //     haveBanner: false,
            //     child: CourseProgressItem(
            //         categoryTitle: 'Design',
            //         hasCategory: true,
            //         categoryPercentage: '75%',
            //         title: 'Product Design',
            //         progress: 0.8,
            //         color: AppColorsDark.accentGreen)
            // ),
          ],
        ),
      ),
    );
  }
}
