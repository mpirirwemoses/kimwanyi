package org.example.util;

import org.example.model.User;
import org.example.model.Notification;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Properties;
import java.util.Random;
import jakarta.mail.*;
import jakarta.mail.internet.*;

public class EmailService {
    
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String EMAIL_USERNAME = "mpirirwemoses2@gmail.com";
    private static final String EMAIL_PASSWORD = "kjpp icia epse svwf"; // Replace with actual app password
    private static final boolean EMAIL_ENABLED = true; // Enabled for live email sending
    
    public static void sendEmail(String to, String subject, String body) {
        if (!EMAIL_ENABLED) {
            System.out.println("Email service disabled. Would send: " + subject + " to " + to);
            return;
        }
        
        try {
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(EMAIL_USERNAME, EMAIL_PASSWORD);
                }
            });
            
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(EMAIL_USERNAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject);
            message.setText(body);
            
            Transport.send(message);
            System.out.println("Email sent successfully to: " + to);
        } catch (Exception e) {
            System.err.println("Failed to send email: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    public static void sendLoanApprovalNotification(User member, String loanReference, double amount) {
        String subject = "Loan Application Approved - Kimwanyi SACCO";
        String body = String.format(
            "Dear %s,\n\n" +
            "Congratulations! Your loan application (%s) has been approved.\n\n" +
            "Loan Details:\n" +
            "- Reference: %s\n" +
            "- Amount: UGX %,.2f\n\n" +
            "Please visit the SACCO office to complete the disbursement process.\n\n" +
            "Best regards,\n" +
            "Kimwanyi SACCO Management",
            member.getFullName(), loanReference, loanReference, amount
        );
        sendEmail(member.getEmail(), subject, body);
    }
    
    public static void sendLoanRejectionNotification(User member, String loanReference, String reason) {
        String subject = "Loan Application Update - Kimwanyi SACCO";
        String body = String.format(
            "Dear %s,\n\n" +
            "We regret to inform you that your loan application (%s) has been rejected.\n\n" +
            "Reason: %s\n\n" +
            "If you have any questions, please visit the SACCO office.\n\n" +
            "Best regards,\n" +
            "Kimwanyi SACCO Management",
            member.getFullName(), loanReference, reason
        );
        sendEmail(member.getEmail(), subject, body);
    }
    
    public static void sendOverdueLoanNotification(User member, String loanReference, int daysOverdue, double balance) {
        String subject = "URGENT: Overdue Loan Alert - Kimwanyi SACCO";
        String body = String.format(
            "Dear %s,\n\n" +
            "This is a reminder that your loan (%s) is now %d days overdue.\n\n" +
            "Outstanding Balance: UGX %,.2f\n\n" +
            "Please make arrangements to settle this loan as soon as possible to avoid additional penalties.\n\n" +
            "Contact us immediately if you are experiencing difficulties.\n\n" +
            "Best regards,\n" +
            "Kimwanyi SACCO Management",
            member.getFullName(), loanReference, daysOverdue, balance
        );
        sendEmail(member.getEmail(), subject, body);
    }
    
    public static void sendWelcomeEmail(User member, String password) {
        String subject = "Welcome to Kimwanyi SACCO";
        String body = String.format(
            "Dear %s,\n\n" +
            "Welcome to Kimwanyi SACCO! Your account has been successfully created.\n\n" +
            "Account Details:\n" +
            "- Membership Number: %s\n" +
            "- Email: %s\n" +
            "- Temporary Password: %s\n\n" +
            "Please login and change your password immediately.\n\n" +
            "Best regards,\n" +
            "Kimwanyi SACCO Management",
            member.getFullName(), member.getMembershipNumber(), member.getEmail(), password
        );
        sendEmail(member.getEmail(), subject, body);
    }
    
    public static void sendMonthlyStatement(User member, double balance, double deposits, double withdrawals) {
        String subject = "Monthly Savings Statement - Kimwanyi SACCO";
        String body = String.format(
            "Dear %s,\n\n" +
            "Here is your monthly savings statement:\n\n" +
            "Current Balance: UGX %,.2f\n" +
            "Total Deposits This Month: UGX %,.2f\n" +
            "Total Withdrawals This Month: UGX %,.2f\n\n" +
            "Thank you for banking with us!\n\n" +
            "Best regards,\n" +
            "Kimwanyi SACCO Management",
            member.getFullName(), balance, deposits, withdrawals
        );
        sendEmail(member.getEmail(), subject, body);
    }
}