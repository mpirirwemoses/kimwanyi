package org.example.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "savings_accounts")
public class SavingsAccount {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "member_id", nullable = false)
    private User member;

    @Column(nullable = false, unique = true, length = 30)
    private String accountNumber;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private SavingsStatus status = SavingsStatus.ACTIVE;

    @Column(nullable = false, precision = 14, scale = 2)
    private BigDecimal balance = BigDecimal.ZERO;

    @Column(nullable = false, precision = 5, scale = 2)
    private BigDecimal interestRate = new BigDecimal("5.00");

    @Column(precision = 14, scale = 2)
    private BigDecimal totalDeposits = BigDecimal.ZERO;

    @Column(precision = 14, scale = 2)
    private BigDecimal totalWithdrawals = BigDecimal.ZERO;

    @Column(precision = 14, scale = 2)
    private BigDecimal totalInterestEarned = BigDecimal.ZERO;

    @Column(precision = 14, scale = 2)
    private BigDecimal minimumBalance = new BigDecimal("100.00");

    @Column(precision = 14, scale = 2)
    private BigDecimal dailyWithdrawalLimit = new BigDecimal("50000.00");

    @Column(precision = 14, scale = 2)
    private BigDecimal dailyWithdrawalAmount = BigDecimal.ZERO;

    @Column(nullable = true)
    private LocalDateTime lastWithdrawalDate;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @Column(nullable = false, updatable = false)
    private LocalDateTime lastInterestCalculation;

    protected SavingsAccount() { }

    public SavingsAccount(User member, String accountNumber) {
        this.member = member;
        this.accountNumber = accountNumber;
    }

    @PrePersist
    private void beforeInsert() {
        LocalDateTime now = LocalDateTime.now();
        createdAt = now;
        updatedAt = now;
        lastInterestCalculation = now;
    }

    @PreUpdate
    private void beforeUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public void deposit(BigDecimal amount) {
        if (amount == null || amount.signum() <= 0) {
            throw new IllegalArgumentException("Deposit amount must be greater than zero.");
        }
        balance = balance.add(amount).setScale(2, RoundingMode.HALF_UP);
        totalDeposits = totalDeposits.add(amount).setScale(2, RoundingMode.HALF_UP);
    }

    public void withdraw(BigDecimal amount) {
        if (amount == null || amount.signum() <= 0) {
            throw new IllegalArgumentException("Withdrawal amount must be greater than zero.");
        }
        if (amount.compareTo(balance) > 0) {
            throw new IllegalArgumentException("Insufficient balance. Current balance: " + balance);
        }
        balance = balance.subtract(amount).setScale(2, RoundingMode.HALF_UP);
        totalWithdrawals = totalWithdrawals.add(amount).setScale(2, RoundingMode.HALF_UP);
    }

    public void applyInterest() {
        if (balance == null || balance.compareTo(BigDecimal.ZERO) <= 0) {
            return;
        }
        BigDecimal monthlyRate = interestRate.divide(new BigDecimal("100"), 10, RoundingMode.HALF_UP)
                .divide(new BigDecimal("12"), 10, RoundingMode.HALF_UP);
        BigDecimal interest = balance.multiply(monthlyRate).setScale(2, RoundingMode.HALF_UP);
        balance = balance.add(interest).setScale(2, RoundingMode.HALF_UP);
        totalInterestEarned = totalInterestEarned.add(interest).setScale(2, RoundingMode.HALF_UP);
        lastInterestCalculation = LocalDateTime.now();
    }
    
    public BigDecimal calculateInterest() {
        if (balance == null || balance.compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }
        BigDecimal monthlyRate = interestRate.divide(new BigDecimal("100"), 10, RoundingMode.HALF_UP)
                .divide(new BigDecimal("12"), 10, RoundingMode.HALF_UP);
        return balance.multiply(monthlyRate).setScale(2, RoundingMode.HALF_UP);
    }

    public Long getId() { return id; }
    public User getMember() { return member; }
    public String getAccountNumber() { return accountNumber; }
    public SavingsStatus getStatus() { return status; }
    public BigDecimal getBalance() { return balance; }
    public BigDecimal getInterestRate() { return interestRate; }
    public BigDecimal getTotalDeposits() { return totalDeposits; }
    public BigDecimal getTotalWithdrawals() { return totalWithdrawals; }
    public BigDecimal getTotalInterestEarned() { return totalInterestEarned; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public LocalDateTime getLastInterestCalculation() { return lastInterestCalculation; }

    public String getCreatedAtFormatted() {
        return createdAt == null || createdAt.getYear() < 1970 ? "" : createdAt.format(java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy HH:mm"));
    }

    public BigDecimal getMinimumBalance() { return minimumBalance; }
    public BigDecimal getDailyWithdrawalLimit() { return dailyWithdrawalLimit; }
    public BigDecimal getDailyWithdrawalAmount() { return dailyWithdrawalAmount; }
    public LocalDateTime getLastWithdrawalDate() { return lastWithdrawalDate; }

    public void setStatus(SavingsStatus status) { this.status = status; }
    public void setInterestRate(BigDecimal interestRate) { this.interestRate = interestRate; }
    public void setAccountNumber(String accountNumber) { this.accountNumber = accountNumber; }
    public void setMinimumBalance(BigDecimal minimumBalance) { this.minimumBalance = minimumBalance; }
    public void setDailyWithdrawalLimit(BigDecimal dailyWithdrawalLimit) { this.dailyWithdrawalLimit = dailyWithdrawalLimit; }
    public void setDailyWithdrawalAmount(BigDecimal dailyWithdrawalAmount) { this.dailyWithdrawalAmount = dailyWithdrawalAmount; }
    public void setLastWithdrawalDate(LocalDateTime lastWithdrawalDate) { this.lastWithdrawalDate = lastWithdrawalDate; }
}
