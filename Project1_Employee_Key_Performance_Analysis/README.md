# Employee KPIs Performance Analysis and Visualization

## Overview

This project addresses 4 main main areas: Employee diversity, KPI performance, employee ratings, and recruitment channels. It offers insights and actionable recommendations to assist the HR department in identifying key challenges and developing strategies to enhance KPI performance, boost employee ratings, and optimize recruitment processes.

__Employee KPI Dashboard:__ [Go to Tableau](https://public.tableau.com/app/profile/aimee.le9707/viz/job_posting_17304343709050/Dashboard2)

## Data Source

The data for this analysis is sourced from Kaggle: [Employee Performance Dataset](https://www.kaggle.com/datasets/sanjanchaudhari/employees-performance-for-hr-analytics).

## Questions Addressed
### Data Cleaning
1. What is the total number of rows and unique employees?
2. How can we identify duplicate records?
3. What is the step to clean and manipulate data? Create a back-up file to remove duplicate and error row

### Employee Overview
4. What is the employee distribution across departments?
5. How is gender distributed across departments?
6. What is the average age of employees in each department?

### KPIs Analysis
7. What is the correlation between KPIs met (>80%) and awards won?
8. How do KPI performances and awards differ by department?
9. What is the impact of training on KPI performance?
10. How does length of service correlate with KPI performance?
11. How does age affect KPI and awards performance?
12. What is the relationship between education and KPI achievement?

### Company Ratings
13. How did employees rate the company last year?
14. How do gender and department correlate with ratings?
15. What is the rating distribution of each department?
16. How does education correlate with ratings?
17. What is the relationship between education level and ratings?

### Company Recruitment
18. How many employees were hired through different recruitment channels?
19. What is the education distribution from different hiring sources?

---

## Analysis Process

1. **Identify Business Problems:** Define key business challenges and objectives.
2. **Data Cleaning:** Profile the data to identify issues, then clean and transform the dataset for analysis.
3. **Data Analysis:** Analyze the data to address the identified problems and derive insights.
4. **Document Findings:** Record key findings and formulate actionable recommendations.

---

### Data cleaning 

- The dataset contained duplicates and entry errors. I created a backup table for future reference, then cleaned the data by removing duplicates and errors in a new staging table. This was transformed into the main table for analysis. 

--> The table was reduced from 17,417 rows to 17,413 by removing 2 duplicate rows and 2 entry errors for employee ID 64573.

---

### Key Findings

#### Employee Diversity
- The largest department is Sales and Marketing, which comprises 31% of the total workforce of 17,417 employees.
- The average age of employees varies by department, ranging from 20 to 60 years, which highlights a significant demographic diversity within the organization.

#### KPI Analysis
- Only 36% of employees achieve KPIs above 80%, indicating a concerning level of performance among staff.
- There is no correlation between award wins and employees meeting KPIs. Employees who do not meet KPIs can still receive awards, while those who do may have lower win rates. For example, the R&D department has a KPI achievement rate of 45% but receives only 1% of the awards.
- The employees that attending training for the first time see a marked improvement, with half of them passing their KPIs. This success rate increases with additional training sessions.
- KPI achievement is significantly higher among employees with bachelor's degrees, reaching 65%, compared to only 29% for master's degree holders. This disparity suggests that the level of education may not be directly related to KPI achievement among employees.

#### Employee Ratings Last Year
- The company’s average employee rating was 3.35 last year. The Sales and Marketing department had the lowest ratings, with 18% of employees giving 1-2 star reviews, indicating dissatisfaction in that department.

#### Recruitment Channels
- Education levels are fairly evenly distributed across different recruitment channels for each department.
- The majority of new hires come from online resources, with only 1.8% recruited through referrals, suggesting an opportunity to increase the role of referrals in the recruitment process.

---

### Recommendations

#### Employee Diversity
- **Targeted Recruitment:** Focus on attracting more female candidates in Sales and Marketing to balance gender representation.
- **Diversity Training:** Implement training programs that promote awareness and support for diversity across all departments.

#### KPI Performance
- **Link Awards to Performance:** Revise the award system to ensure that it reflects actual KPI achievements, motivating employees to meet their goals.
- **Increase Training Access:** Expand training opportunities, especially for those new to the company, to improve KPI achievement rates.
- **Implement Performance Reviews:** Regular performance reviews can help track employee progress and address any concerns promptly.
- **Support for Underperformers:** Provide tailored support and coaching for employees struggling to meet KPIs, focusing on their development.

#### Employee Satisfaction
- **Conduct In-Depth Surveys:** Gather feedback from departments with low ratings (e.g., Sales and Marketing) to pinpoint specific issues and develop targeted improvement plans.
- **Recognition Beyond KPIs:** Create a recognition program that values contributions outside of KPI metrics, fostering a positive work environment.

#### Recruitment Channels
- **Enhance Employee Referral Program:** Increase incentives for employees to refer candidates, aiming to diversify recruitment sources beyond "other" channels.
- **Analyze Recruitment Effectiveness:** Regularly assess the success of different recruitment channels to ensure they align with diversity and quality hiring goals.


## Conclusion

In summary, the organization faces challenges related to employee performance, particularly in Sales and Marketing, where a notable percentage of employees rated their experience low. Additionally, the recruitment process shows an overreliance on non-traditional hiring channels, with a minimal contribution from referrals. However, the recruitment team has effectively ensured a diverse range of educational backgrounds among hires across departments. Addressing the low performance in specific areas and enhancing referral strategies could lead to improved employee satisfaction and overall organizational effectiveness.

## License

MIT license

Copyright (c) [2024] [Aimee Le]
