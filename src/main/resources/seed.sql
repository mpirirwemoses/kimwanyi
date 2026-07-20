-- Credit SACCO Database Seed Data
-- Run this script to populate the database with sample data

-- Insert sample users (passwords are hashed versions of 'password123')
INSERT INTO users (full_name, email, password_hash, role, membership_number, national_id, phone_number, physical_address, date_of_birth, status, created_at, updated_at) VALUES
('John Kamau', 'john.kamau@example.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'MEMBER', 'MEM001', '12345678', '+254712345678', '123 Nairobi Street, Kenya', '1985-03-15', 'ACTIVE', NOW(), NOW()),
('Jane Wanjiku', 'jane.wanjiku@example.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'MEMBER', 'MEM002', '87654321', '+254723456789', '456 Mombasa Road, Kenya', '1990-07-22', 'ACTIVE', NOW(), NOW()),
('Admin User', 'admin@creditsacco.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'ADMIN', NULL, NULL, '+254700000000', 'SACCO Headquarters', '1980-01-01', 'ACTIVE', NOW(), NOW());

-- Insert sample loans for John Kamau (user_id = 1)
INSERT INTO loans (member_id, requested_amount, purpose, status, applied_at, reviewed_at, reviewed_by_id, review_comment, total_repayable, interest_rate, payment_mode, due_date, loan_reference, outstanding_balance) VALUES
(1, 50000.00, 'Business expansion - buying inventory for retail shop', 'APPROVED', NOW() - INTERVAL 30 DAY, NOW() - INTERVAL 28 DAY, 3, 'Approved - good credit history', 55000.00, 10.00, 'MPESA', NOW() + INTERVAL 5 MONTH, 'LN-1704067200000', 55000.00),
(1, 30000.00, 'School fees payment for children', 'PENDING', NOW() - INTERVAL 2 DAY, NULL, NULL, NULL, NULL, 10.00, 'MPESA', NULL, 'LN-1704067300000', NULL),
(1, 25000.00, 'Home renovation - kitchen and bathroom', 'REPAID', NOW() - INTERVAL 90 DAY, NOW() - INTERVAL 88 DAY, 3, 'Approved', 27500.00, 10.00, 'BANK_TRANSFER', NOW() - INTERVAL 20 DAY, 'LN-1704067400000', 0.00);

-- Insert sample loans for Jane Wanjiku (user_id = 2)
INSERT INTO loans (member_id, requested_amount, purpose, status, applied_at, reviewed_at, reviewed_by_id, review_comment, total_repayable, interest_rate, payment_mode, due_date, loan_reference, outstanding_balance) VALUES
(2, 80000.00, 'Purchase of commercial vehicle for transport business', 'APPROVED', NOW() - INTERVAL 60 DAY, NOW() - INTERVAL 58 DAY, 3, 'Approved - viable business plan', 88000.00, 10.00, 'MPESA', NOW() + INTERVAL 3 MONTH, 'LN-1704067500000', 88000.00),
(2, 15000.00, 'Medical emergency - family health insurance', 'REJECTED', NOW() - INTERVAL 45 DAY, NOW() - INTERVAL 43 DAY, 3, 'Rejected - insufficient savings history', NULL, 10.00, 'MPESA', NULL, 'LN-1704067600000', NULL);

-- Insert sample payments for John Kamau's repaid loan
INSERT INTO payments (loan_id, member_id, amount, payment_method, card_last_four, transaction_id, payment_date, notes) VALUES
(3, 1, 13750.00, 'BANK_TRANSFER', NULL, 'TXN-ABC12345', NOW() - INTERVAL 75 DAY, 'First installment'),
(3, 1, 13750.00, 'MPESA', NULL, 'TXN-XYZ67890', NOW() - INTERVAL 50 DAY, 'Second installment'),
(3, 1, 13750.00, 'MPESA', NULL, 'TXN-DEF11111', NOW() - INTERVAL 25 DAY, 'Final installment');

-- Insert sample payment for Jane Wanjiku's active loan
INSERT INTO payments (loan_id, member_id, amount, payment_method, card_last_four, transaction_id, payment_date, notes) VALUES
(4, 2, 20000.00, 'MPESA', NULL, 'TXN-GHI22222', NOW() - INTERVAL 30 DAY, 'First partial payment');