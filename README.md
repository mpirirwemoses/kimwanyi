# Credit SACCO - Enhanced Loan Management System

## Overview
This is a comprehensive loan management system for a SACCO (Savings and Credit Cooperative Organization) with modern member dashboard, loan application, payment processing, and history tracking features.

## Features Implemented

### 1. Modern Member Dashboard
- **Sidebar Navigation**: Clean, modern sidebar with icons and navigation menu
- **Statistics Cards**: Real-time display of:
  - Active loans count
  - Total outstanding balance
  - Next payment due date
  - Total amount repaid
- **Quick Actions**: Easy access to apply for loans, view payment history, and more
- **Recent Loans**: Quick overview of recent loan applications
- **Responsive Design**: Works on desktop and mobile devices

### 2. Enhanced Loan Application System
- **Dedicated Application Page**: Professional loan application form (`loan-application.jsp`)
- **Real-time Preview**: Shows estimated total repayment with 10% interest
- **Purpose Examples**: Clickable examples for common loan purposes
- **Form Validation**: Client and server-side validation
- **Business Rules**:
  - 10% interest rate per annum
  - Maximum loan: 3x savings balance (placeholder for savings module)
  - Minimum repayment: KES 100 or 1/3 of outstanding balance
  - 6-month repayment period

### 3. Comprehensive Loan Management
- **Loan Details Display**:
  - Loan reference number
  - Requested amount and purpose
  - Interest rate (10%)
  - Payment mode (M-Pesa, Card, Bank Transfer)
  - Due date (6 months from approval)
  - Total repayable amount
  - Outstanding balance
  - Review comments from admin

### 4. Payment Processing System
- **Multiple Payment Methods**:
  - M-Pesa (mobile money)
  - Credit/Debit Card (Visa, Mastercard)
  - Bank Transfer
  - Cash
- **Card Payment Support**: Card number input with last 4 digits tracking
- **Payment Validation**: Minimum and maximum payment amounts
- **Transaction Tracking**: Unique transaction IDs for all payments

### 5. Payment History Tracking
- **Comprehensive History Page**: `payment-history.jsp`
- **Summary Statistics**:
  - Total number of payments
  - Total amount paid
  - Average payment amount
- **Detailed Transaction Table**:
  - Date and time
  - Transaction ID
  - Loan reference
  - Payment method (with icons)
  - Amount
  - Notes
- **Method Badges**: Color-coded badges for different payment methods

### 6. Enhanced Data Model
- **Loan Model** additions:
  - `interestRate`: 10% per annum
  - `paymentMode`: Preferred payment method
  - `dueDate`: 6 months from approval
  - `loanReference`: Unique loan identifier
- **Payment Model**: New entity for tracking all repayments
- **PaymentMethod Enum**: CARD, MPESA, BANK_TRANSFER, CASH

### 7. Database Seed Data
Sample data for testing (`seed.sql`):
- 3 users (2 members, 1 admin)
- 5 loans with various statuses (PENDING, APPROVED, REPAID, REJECTED)
- 4 payment records showing payment history
- Realistic loan purposes and amounts

## File Structure

### Java Models
- `src/main/java/org/example/model/Loan.java` - Enhanced loan entity
- `src/main/java/org/example/model/Payment.java` - Payment tracking entity
- `src/main/java/org/example/model/PaymentMethod.java` - Payment method enum
- `src/main/java/org/example/model/User.java` - User entity
- `src/main/java/org/example/model/LoanStatus.java` - Loan status enum
- `src/main/java/org/example/model/AccountStatus.java` - Account status enum

### Servlets
- `src/main/java/org/example/web/LoanServlet.java` - Loan operations
- `src/main/java/org/example/web/PaymentServlet.java` - Payment processing
- `src/main/java/org/example/web/DashboardServlet.java` - Dashboard routing
- `src/main/java/org/example/web/DashboardApiServlet.java` - Dashboard data API
- `src/main/java/org/example/web/AuthServlet.java` - Authentication

### JSP Views
- `src/main/webapp/WEB-INF/views/member-dashboard.jsp` - Modern member dashboard
- `src/main/webapp/WEB-INF/views/loan-application.jsp` - Loan application form
- `src/main/webapp/WEB-INF/views/member-loans.jsp` - Member's loan list
- `src/main/webapp/WEB-INF/views/payment-form.jsp` - Payment processing form
- `src/main/webapp/WEB-INF/views/payment-history.jsp` - Payment history page
- `src/main/webapp/WEB-INF/views/dashboard.jsp` - Legacy dashboard (kept for compatibility)
- `src/main/webapp/WEB-INF/views/admin-dashboard.jsp` - Admin dashboard
- `src/main/webapp/WEB-INF/views/admin-loans.jsp` - Admin loan management

### Configuration
- `src/main/resources/hibernate.cfg.xml` - Database configuration
- `src/main/resources/seed.sql` - Sample data script
- `src/main/webapp/assets/styles.css` - Modern CSS styling

## Database Schema

### Users Table
- id, full_name, email, password_hash, role
- membership_number, national_id, phone_number
- physical_address, date_of_birth, status
- created_at, updated_at

### Loans Table
- id, member_id, requested_amount, purpose
- status (PENDING, APPROVED, REJECTED, CANCELLED, REPAID, OVERDUE)
- applied_at, reviewed_at, reviewed_by_id, review_comment
- total_repayable, interest_rate, payment_mode
- due_date, loan_reference, outstanding_balance

### Payments Table
- id, loan_id, member_id, amount
- payment_method (CARD, MPESA, BANK_TRANSFER, CASH)
- card_last_four, transaction_id
- payment_date, notes

## Setup Instructions

### Prerequisites
- Java 17+
- MySQL 8.0+
- Maven 3.8+
- Tomcat 10+ or compatible servlet container

### Database Setup
1. Create MySQL database named `credit`:
   ```sql
   CREATE DATABASE credit;
   ```

2. Run the seed script to populate sample data:
   ```bash
   mysql -u root -p credit < src/main/resources/seed.sql
   ```

3. Update database credentials in `hibernate.cfg.xml` if needed

### Build and Deploy
```bash
# Compile the project
mvn clean compile

# Package as WAR
mvn package

# Deploy the WAR file to Tomcat
# Copy target/creditSacco-1.0-SNAPSHOT.war to Tomcat webapps/
```

### Access the Application
- Member login: Use credentials from seed.sql
  - Email: `john.kamau@example.com` or `jane.wanjiku@example.com`
  - Password: `password123`
- Admin login:
  - Email: `admin@creditsacco.com`
  - Password: `password123`

## User Workflows

### Member Workflow
1. **Login** → Redirected to modern dashboard
2. **Dashboard** → View statistics and quick actions
3. **Apply for Loan** → Fill application form with real-time preview
4. **View Loans** → See all loans with status badges
5. **Make Payment** → Select payment method and process payment
6. **Payment History** → View all transactions with filters

### Admin Workflow
1. **Login** → Access admin dashboard
2. **Review Loans** → View pending applications
3. **Approve/Reject** → Add comments and set loan terms
4. **Monitor** → Track all loans and payments

## Technical Highlights

### Security
- Password hashing with BCrypt
- Session-based authentication
- XSS protection with HTML escaping
- SQL injection prevention with parameterized queries

### Modern UI/UX
- Clean, professional design
- Responsive layout (mobile-friendly)
- SVG icons for better performance
- Smooth animations and transitions
- Color-coded status badges
- Interactive form elements

### Business Logic
- Automatic interest calculation (10%)
- Due date calculation (6 months)
- Loan amount validation
- Payment allocation and balance updates
- Status transitions (PENDING → APPROVED → REPAID)

### Database Design
- Proper foreign key relationships
- Cascade operations where appropriate
- Indexed columns for performance
- Nullable fields for optional data

## Future Enhancements
- Savings account module (placeholder exists)
- Email notifications
- PDF statement generation
- Advanced reporting and analytics
- Mobile app API
- Payment gateway integration (Stripe/PayPal)
- Loan amortization schedules
- Multi-currency support

## Troubleshooting

### "Zero date value prohibited" Error
- Fixed by adding `zeroDateTimeBehavior=CONVERT_TO_NULL` to JDBC URL
- Updated seed.sql to use `DATE_SUB()` and `DATE_ADD()` functions

### Compilation Errors
- Ensure all dependencies are in `pom.xml`
- Run `mvn clean compile` to rebuild
- Check Java version (requires Java 17+)

### Database Connection Issues
- Verify MySQL is running
- Check credentials in `hibernate.cfg.xml`
- Ensure database `credit` exists

## License
This project is developed for educational and commercial use.

## Support
For issues or questions, please contact the development team.