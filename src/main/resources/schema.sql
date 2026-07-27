-- Kimwanyi SACCO Database Schema
-- Run this script to create all necessary tables

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(10) NOT NULL DEFAULT 'MEMBER',
    membership_number VARCHAR(30) UNIQUE,
    national_id VARCHAR(30) UNIQUE,
    phone_number VARCHAR(30),
    physical_address VARCHAR(255),
    date_of_birth DATE,
    status VARCHAR(10) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Savings accounts table
CREATE TABLE IF NOT EXISTS savings_accounts (
    id BIGSERIAL PRIMARY KEY,
    member_id BIGINT NOT NULL REFERENCES users(id),
    account_number VARCHAR(30) UNIQUE NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'ACTIVE',
    balance DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    interest_rate DECIMAL(5,2) NOT NULL DEFAULT 6.00,
    total_deposits DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    total_withdrawals DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    total_interest_earned DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    minimum_balance DECIMAL(14,2) NOT NULL DEFAULT 100.00,
    daily_withdrawal_limit DECIMAL(14,2) NOT NULL DEFAULT 50000.00,
    daily_withdrawal_amount DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    last_withdrawal_date TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_interest_calculation TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Savings transactions table
CREATE TABLE IF NOT EXISTS savings_transactions (
    id BIGSERIAL PRIMARY KEY,
    savings_account_id BIGINT NOT NULL REFERENCES savings_accounts(id),
    transaction_type VARCHAR(20) NOT NULL,
    amount DECIMAL(14,2) NOT NULL,
    balance_before DECIMAL(14,2) NOT NULL,
    balance_after DECIMAL(14,2) NOT NULL,
    transaction_reference VARCHAR(50) UNIQUE NOT NULL,
    transaction_id VARCHAR(50),
    card_last_four VARCHAR(4),
    notes VARCHAR(500),
    transaction_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Loans table
CREATE TABLE IF NOT EXISTS loans (
    id BIGSERIAL PRIMARY KEY,
    member_id BIGINT NOT NULL REFERENCES users(id),
    requested_amount DECIMAL(14,2) NOT NULL,
    purpose VARCHAR(500) NOT NULL,
    status VARCHAR(12) NOT NULL DEFAULT 'PENDING',
    applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP,
    reviewed_by_id BIGINT REFERENCES users(id),
    review_comment VARCHAR(500),
    total_repayable DECIMAL(14,2),
    interest_rate DECIMAL(5,2) NOT NULL DEFAULT 10.00,
    payment_mode VARCHAR(20) NOT NULL DEFAULT 'MPESA',
    due_date TIMESTAMP,
    loan_reference VARCHAR(50) UNIQUE NOT NULL,
    outstanding_balance DECIMAL(14,2),
    interest_calculation_period VARCHAR(10) NOT NULL DEFAULT 'MONTHLY',
    last_interest_calculated DECIMAL(14,2),
    last_interest_calculation_date TIMESTAMP
);

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    message VARCHAR(500) NOT NULL,
    recipient_type VARCHAR(10) NOT NULL,
    recipient_id BIGINT REFERENCES users(id),
    read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Audit logs table
CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    action VARCHAR(50) NOT NULL,
    details VARCHAR(500) NOT NULL,
    ip_address VARCHAR(50) NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Payments table
CREATE TABLE IF NOT EXISTS payments (
    id BIGSERIAL PRIMARY KEY,
    loan_id BIGINT NOT NULL REFERENCES loans(id),
    amount DECIMAL(14,2) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    payment_reference VARCHAR(50) UNIQUE NOT NULL,
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes VARCHAR(500)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_membership ON users(membership_number);
CREATE INDEX IF NOT EXISTS idx_users_national_id ON users(national_id);
CREATE INDEX IF NOT EXISTS idx_savings_accounts_member ON savings_accounts(member_id);
CREATE INDEX IF NOT EXISTS idx_savings_accounts_number ON savings_accounts(account_number);
CREATE INDEX IF NOT EXISTS idx_savings_transactions_account ON savings_transactions(savings_account_id);
CREATE INDEX IF NOT EXISTS idx_loans_member ON loans(member_id);
CREATE INDEX IF NOT EXISTS idx_loans_status ON loans(status);
CREATE INDEX IF NOT EXISTS idx_loans_reference ON loans(loan_reference);
CREATE INDEX IF NOT EXISTS idx_loans_due_date ON loans(due_date);
CREATE INDEX IF NOT EXISTS idx_notifications_recipient ON notifications(recipient_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_timestamp ON audit_logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_payments_loan ON payments(loan_id);

-- Insert default admin user (password: admin123)
INSERT INTO users (full_name, email, password_hash, role, membership_number, national_id, status)
VALUES ('System Administrator', 'admin@kimwanyi.co.ug', '$2a$10$rQ7H1H7H7H7H7H7H7H7H7O', 'ADMIN', 'ADMIN-001', 'ADMIN-NATIONAL-ID', 'ACTIVE')
ON CONFLICT (email) DO NOTHING;