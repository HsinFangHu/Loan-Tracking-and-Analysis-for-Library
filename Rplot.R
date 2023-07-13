install.packages("RSQLite")
library(RSQLite)
library(ggplot2)

conn <- dbConnect(RSQLite::SQLite(), dbname = "/Users/hsinhu/Desktop/AD688/AD688_Assignment2/LibraryLoan.db")

query <- "SELECT strftime('%Y-%m', date_checked_out) AS checkout_month, COUNT(*) AS rental_count
FROM Loan_Trans
WHERE date_checked_out BETWEEN '2021-01-01' AND '2022-12-31'
GROUP BY checkout_month
ORDER BY checkout_month ASC"
result <- dbGetQuery(conn, query)

ggplot(result, aes(x = checkout_month, y = rental_count)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(x = "Year-Month", y = "Rental Count") +
  ggtitle("Trend of Rentals per Year-Month")



query_count <- "SELECT 'Senior' AS Age_Group, COUNT(*) AS Total_count FROM Senior
UNION ALL
SELECT 'Young Adulthood' AS Age_Group, COUNT(*) AS Total_count FROM Young_adulthood
UNION ALL
SELECT 'Middle' AS Age_Group, COUNT(*) AS Total_count FROM Middle"
result_count <- dbGetQuery(conn, query_count)

query_no_loan <- "SELECT 'Senior' AS Age_Group, COUNT(*) AS No_Loan_Count FROM Senior
                  WHERE patron_id NOT IN (SELECT patron_id FROM Loan_Trans)
                  UNION ALL
                  SELECT 'Young Adulthood' AS Age_Group, COUNT(*) AS No_Loan_Count FROM Young_adulthood
                  WHERE patron_id NOT IN (SELECT patron_id FROM Loan_Trans)
                  UNION ALL
                  SELECT 'Middle' AS Age_Group, COUNT(*) AS No_Loan_Count FROM Middle
                  WHERE patron_id NOT IN (SELECT patron_id FROM Loan_Trans)"
result_no_loan <- dbGetQuery(conn, query_no_loan)

result_merged <- merge(result_count, result_no_loan, by.x = "Age_Group", by.y = "Age_Group", all.x = TRUE)

bar_plot <- ggplot(data, aes(x = Age_Group)) +
  geom_bar(aes(y = Total_count, fill = "Total Count"), stat = "identity", position = "stack") +
  geom_bar(aes(y = No_Loan_Count, fill = "No Loan Count"), stat = "identity", position = "stack") +
  labs(title = "Number of Individuals in Each Age Group",
       x = "Age Group",
       y = "Count",
       fill = "") +
  scale_fill_manual(values = c("Total Count" = "darkcyan", "No Loan Count" = "coral"))
bar_plot

