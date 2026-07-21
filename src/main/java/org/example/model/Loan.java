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
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

@Entity
@Table(name = "loans")
public class Loan {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "member_id", nullable = false)
    private User member;

    @Column(nullable = false, precision = 14, scale = 2)
    private BigDecimal requestedAmount;

    @Column(nullable = false, length = 500)
    private String purpose;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 12)
    private LoanStatus status = LoanStatus.PENDING;

    @Column(nullable = false, updatable = false)
    private LocalDateTime appliedAt;

    private LocalDateTime reviewedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reviewed_by_id")
    private User reviewedBy;

    @Column(length = 500)
    private String reviewComment;

    @Column(precision = 14, scale = 2)
    private BigDecimal totalRepayable;

    @Column(precision = 5, scale = 2)
    private BigDecimal interestRate = new BigDecimal("10.00");

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    @org.hibernate.annotations.ColumnDefault("'MPESA'")
    private PaymentMethod paymentMode = PaymentMethod.MPESA;

    private LocalDateTime dueDate;

    @Column(length = 50)
    private String loanReference;

    @Column(precision = 14, scale = 2)
    private BigDecimal outstandingBalance;

    protected Loan() { }

    public Loan(User member, BigDecimal requestedAmount, String purpose) {
        this.member = member;
        this.requestedAmount = requestedAmount;
        this.purpose = purpose;
        this.loanReference = "LN-" + System.currentTimeMillis();
    }

    @PrePersist
    private void beforeInsert() { appliedAt = LocalDateTime.now().truncatedTo(ChronoUnit.MINUTES); }

    public void updateApplication(BigDecimal amount, String newPurpose) {
        if (status != LoanStatus.PENDING) throw new IllegalStateException("Only pending applications can be changed.");
        requestedAmount = amount;
        purpose = newPurpose;
    }

    public void cancel() {
        if (status != LoanStatus.PENDING) throw new IllegalStateException("Only pending applications can be cancelled.");
        status = LoanStatus.CANCELLED;
    }

    public void approve(User admin, String comment) {
        if (status != LoanStatus.PENDING) throw new IllegalStateException("Only pending applications can be approved.");
        status = LoanStatus.APPROVED;
        reviewedBy = admin;
        reviewedAt = LocalDateTime.now();
        reviewComment = comment;
        totalRepayable = requestedAmount.multiply(new BigDecimal("1.10")).setScale(2, RoundingMode.HALF_UP);
        outstandingBalance = totalRepayable;
        dueDate = LocalDateTime.now().plusMonths(6);
    }

    public void reject(User admin, String comment) {
        if (status != LoanStatus.PENDING) throw new IllegalStateException("Only pending applications can be rejected.");
        status = LoanStatus.REJECTED;
        reviewedBy = admin;
        reviewedAt = LocalDateTime.now();
        reviewComment = comment;
    }

    public void repay(BigDecimal amount) {
        if (status != LoanStatus.APPROVED) throw new IllegalStateException("Only approved loans can be repaid.");
        if (amount == null || amount.signum() <= 0) throw new IllegalArgumentException("Repayment amount must be greater than zero.");
        if (outstandingBalance == null) throw new IllegalStateException("Loan has no outstanding balance.");
        if (amount.compareTo(outstandingBalance) > 0) throw new IllegalArgumentException("Repayment exceeds outstanding balance.");
        outstandingBalance = outstandingBalance.subtract(amount).setScale(2, RoundingMode.HALF_UP);
        if (outstandingBalance.compareTo(BigDecimal.ZERO) == 0) {
            status = LoanStatus.REPAID;
        }
    }

    public Long getId() { return id; }
    public User getMember() { return member; }
    public BigDecimal getRequestedAmount() { return requestedAmount; }
    public String getPurpose() { return purpose; }
    public LoanStatus getStatus() { return status; }
    public LocalDateTime getAppliedAt() { return appliedAt; }

    public String getAppliedAtFormatted() {
        return appliedAt == null || appliedAt.getYear() < 1970 ? "" : appliedAt.format(java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy HH:mm"));
    }

    public String getReviewedAtFormatted() {
        return reviewedAt == null || reviewedAt.getYear() < 1970 ? "" : reviewedAt.format(java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy HH:mm"));
    }

    public String getDueDateFormatted() {
        return dueDate == null || dueDate.getYear() < 1970 ? "" : dueDate.format(java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy HH:mm"));
    }
    public LocalDateTime getReviewedAt() { return reviewedAt; }
    public User getReviewedBy() { return reviewedBy; }
    public String getReviewComment() { return reviewComment; }
    public BigDecimal getTotalRepayable() { return totalRepayable; }
    public BigDecimal getInterestRate() { return interestRate; }
    public PaymentMethod getPaymentMode() { return paymentMode; }
    public LocalDateTime getDueDate() { return dueDate; }
    public String getLoanReference() { return loanReference; }
    public BigDecimal getOutstandingBalance() { return outstandingBalance; }
    public void setOutstandingBalance(BigDecimal outstandingBalance) { this.outstandingBalance = outstandingBalance; }
    public void setTotalRepayable(BigDecimal totalRepayable) { this.totalRepayable = totalRepayable; }
    public void setDueDate(LocalDateTime dueDate) { this.dueDate = dueDate; }
    public void setLoanReference(String loanReference) { this.loanReference = loanReference; }
}
