package org.example.util;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Central validation utility for business rules across the SACCO application.
 *
 * Business Rules Enforced:
 * - Savings interest: 5% per annum, applied monthly
 * - Minimum savings balance: UGX 20,000 must be maintained at all times
 * - Maximum loan amount: 3x the member's current savings balance
 * - Loan interest: 10% flat rate of the principal
 * - A member may only hold one active loan at a time
 * - A loan must be fully repaid before a new loan can be applied for
 * - A member cannot withdraw more than their available savings balance
 */
public final class ValidationUtil {

    // ===== Business Rule Constants =====

    /** Minimum savings balance that must be maintained at all times (UGX 20,000). */
    public static final BigDecimal MIN_SAVINGS_BALANCE = new BigDecimal("20000.00");

    /** Savings interest rate: 5% per annum, applied monthly. */
    public static final BigDecimal SAVINGS_INTEREST_RATE = new BigDecimal("5.00");

    /** Loan interest rate: 10% flat rate of the principal. */
    public static final BigDecimal LOAN_INTEREST_RATE = new BigDecimal("10.00");

    /** Maximum loan amount is this multiplier times the member's savings balance. */
    public static final BigDecimal MAX_LOAN_MULTIPLIER = new BigDecimal("3");

    /** Minimum deposit amount per transaction. */
    public static final BigDecimal MIN_DEPOSIT_AMOUNT = new BigDecimal("100.00");

    /** Maximum deposit amount per transaction. */
    public static final BigDecimal MAX_DEPOSIT_AMOUNT = new BigDecimal("500000.00");

    /** Minimum withdrawal amount per transaction. */
    public static final BigDecimal MIN_WITHDRAWAL_AMOUNT = new BigDecimal("100.00");

    /** Minimum loan amount. */
    public static final BigDecimal MIN_LOAN_AMOUNT = new BigDecimal("100.00");

    /** Default maximum loan when savings balance is zero (fallback). */
    public static final BigDecimal DEFAULT_MAX_LOAN = new BigDecimal("100000.00");

    private ValidationUtil() {
        // Utility class - prevent instantiation
    }

    // ===== Loan Validation =====

    /**
     * Validates that the requested loan amount does not exceed the maximum allowed
     * (3x the member's current savings balance).
     *
     * @param requestedAmount the loan amount requested by the member
     * @param savingsBalance  the member's current savings balance
     * @return the maximum allowed loan amount
     * @throws IllegalArgumentException if the requested amount exceeds the maximum
     */
    public static BigDecimal validateLoanAmount(BigDecimal requestedAmount, BigDecimal savingsBalance) {
        BigDecimal maxLoan;
        if (savingsBalance == null || savingsBalance.compareTo(BigDecimal.ZERO) == 0) {
            maxLoan = DEFAULT_MAX_LOAN;
        } else {
            maxLoan = savingsBalance.multiply(MAX_LOAN_MULTIPLIER);
        }
        maxLoan = maxLoan.setScale(2, RoundingMode.HALF_UP);

        if (requestedAmount.compareTo(maxLoan) > 0) {
            throw new IllegalArgumentException(
                "Requested loan amount UGX " + requestedAmount +
                " exceeds the maximum allowed amount of UGX " + maxLoan +
                " (3x your savings balance of UGX " + savingsBalance + ")."
            );
        }
        return maxLoan;
    }

    /**
     * Validates that the requested loan amount is at least the minimum.
     *
     * @param requestedAmount the loan amount requested by the member
     * @throws IllegalArgumentException if the amount is below the minimum
     */
    public static void validateMinLoanAmount(BigDecimal requestedAmount) {
        if (requestedAmount.compareTo(MIN_LOAN_AMOUNT) < 0) {
            throw new IllegalArgumentException(
                "Minimum loan amount is UGX " + MIN_LOAN_AMOUNT + "."
            );
        }
    }

    /**
     * Calculates the total repayment amount for a loan (principal + 10% flat interest).
     *
     * @param principal the loan principal amount
     * @return the total repayment amount (principal + 10% interest)
     */
    public static BigDecimal calculateLoanTotalRepayment(BigDecimal principal) {
        return principal.multiply(new BigDecimal("1.10")).setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * Calculates the loan interest amount (10% flat rate of the principal).
     *
     * @param principal the loan principal amount
     * @return the interest amount
     */
    public static BigDecimal calculateLoanInterest(BigDecimal principal) {
        return principal.multiply(LOAN_INTEREST_RATE.divide(new BigDecimal("100")))
                .setScale(2, RoundingMode.HALF_UP);
    }

    // ===== Savings Validation =====

    /**
     * Validates that a withdrawal does not violate the minimum balance requirement.
     *
     * @param balance          the current account balance
     * @param withdrawalAmount the amount to withdraw
     * @param minimumBalance   the minimum balance that must be maintained (may be null)
     * @throws IllegalArgumentException if the withdrawal would violate the minimum balance
     */
    public static void validateWithdrawal(BigDecimal balance, BigDecimal withdrawalAmount, BigDecimal minimumBalance) {
        BigDecimal effectiveMinBalance = minimumBalance != null ? minimumBalance : MIN_SAVINGS_BALANCE;
        BigDecimal balanceAfterWithdrawal = balance.subtract(withdrawalAmount);

        if (balanceAfterWithdrawal.compareTo(effectiveMinBalance) < 0) {
            BigDecimal maxWithdrawable = balance.subtract(effectiveMinBalance);
            throw new IllegalArgumentException(
                "Withdrawal would violate the minimum balance requirement of UGX " + effectiveMinBalance +
                ". Maximum withdrawable amount: UGX " + maxWithdrawable + "."
            );
        }
    }

    /**
     * Validates that the withdrawal amount does not exceed the available balance.
     *
     * @param balance          the current account balance
     * @param withdrawalAmount the amount to withdraw
     * @throws IllegalArgumentException if the withdrawal exceeds the available balance
     */
    public static void validateWithdrawalDoesNotExceedBalance(BigDecimal balance, BigDecimal withdrawalAmount) {
        if (withdrawalAmount.compareTo(balance) > 0) {
            throw new IllegalArgumentException(
                "Withdrawal amount UGX " + withdrawalAmount +
                " exceeds your available balance of UGX " + balance + "."
            );
        }
    }

    /**
     * Validates that the withdrawal amount is at least the minimum.
     *
     * @param withdrawalAmount the amount to withdraw
     * @throws IllegalArgumentException if the amount is below the minimum
     */
    public static void validateMinWithdrawalAmount(BigDecimal withdrawalAmount) {
        if (withdrawalAmount.compareTo(MIN_WITHDRAWAL_AMOUNT) < 0) {
            throw new IllegalArgumentException(
                "Minimum withdrawal amount is UGX " + MIN_WITHDRAWAL_AMOUNT + "."
            );
        }
    }

    /**
     * Calculates the maximum withdrawable amount (balance - minimum balance).
     *
     * @param balance        the current account balance
     * @param minimumBalance the minimum balance that must be maintained (may be null)
     * @return the maximum withdrawable amount
     */
    public static BigDecimal calculateMaxWithdrawable(BigDecimal balance, BigDecimal minimumBalance) {
        BigDecimal effectiveMinBalance = minimumBalance != null ? minimumBalance : MIN_SAVINGS_BALANCE;
        BigDecimal maxWithdrawable = balance.subtract(effectiveMinBalance);
        if (maxWithdrawable.compareTo(BigDecimal.ZERO) < 0) {
            return BigDecimal.ZERO;
        }
        return maxWithdrawable.setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * Calculates monthly savings interest (5% per annum applied monthly).
     *
     * @param balance the current savings balance
     * @return the monthly interest amount
     */
    public static BigDecimal calculateMonthlySavingsInterest(BigDecimal balance) {
        // Monthly rate = annual rate / 12
        BigDecimal monthlyRate = SAVINGS_INTEREST_RATE.divide(new BigDecimal("12"), 10, RoundingMode.HALF_UP);
        return balance.multiply(monthlyRate).setScale(2, RoundingMode.HALF_UP);
    }

    // ===== Generic Validation =====

    /**
     * Validates that a BigDecimal amount is positive.
     *
     * @param amount    the amount to validate
     * @param fieldName the name of the field being validated
     * @throws IllegalArgumentException if the amount is null or not positive
     */
    public static void validatePositiveAmount(BigDecimal amount, String fieldName) {
        if (amount == null || amount.signum() <= 0) {
            throw new IllegalArgumentException(fieldName + " must be greater than zero.");
        }
    }

    /**
     * Validates that a string is not blank and within the specified length.
     *
     * @param value     the string to validate
     * @param fieldName the name of the field being validated
     * @param maxLength the maximum allowed length
     * @throws IllegalArgumentException if the value is blank or too long
     */
    public static void validateNotBlank(String value, String fieldName, int maxLength) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(fieldName + " cannot be empty.");
        }
        if (value.length() > maxLength) {
            throw new IllegalArgumentException(fieldName + " cannot exceed " + maxLength + " characters.");
        }
    }
}