resource "aws_budgets_budget" "budget" {
  name = "monthly_budget"
  budget_type = "COST"
  limit_amount = "5.0"
  limit_unit = "USD"
  time_unit = "MONTHLY"

  notification {
    comparison_operator = "GREATER_THAN"
    threshold = 80
    threshold_type = "PERCENTAGE"
    notification_type = "FORECASTED"
    subscriber_email_addresses = [ var.bugets_e_mail ]
  }
}