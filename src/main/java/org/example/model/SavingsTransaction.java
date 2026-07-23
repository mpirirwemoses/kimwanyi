package org.example.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "savings_transactions")
public class SavingsTransaction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = jakarta.persistence.FetchType.LAZY, optional = false)
    @JoinColumn(name = "savings_account_id", nullable = false)
    private SavingsAccount savingsAccount;

    @ManyToOne(fetch = jakarta.persistence.FetchType.LAZY, optional = false)
    @JoinColumn(name = "member_id", nullable = false)
    private User member;

    @Enumerated(EnumType.STRING)
    @Column(name = "transaction_type", nullable = false, length = 20)
    private TransactionType type;

    @Column(nullable = false, precision = 14, scale = 2)
    private BigDecimal amount;

    @Column(name = "balance_before", nullable = false, precision = 14, scale = 2)
    private BigDecimal balanceBefore;

    @Column(name = "balance_after", nullable = false, precision = 14, scale = 2)
    private BigDecimal balanceAfter;

    @Column(name = "transaction_reference", length = 50)
    private String transactionReference;

    @Column(name = "card_last_four", length = 100)
    private String cardLastFour;

    @Column(name = "transaction_id", length = 50)
    private String transactionId;

    @Column(name = "transaction_date", nullable = false, updatable = false)
    private LocalDateTime transactionDate;

    @Column(length = 500)
    private String notes;

    protected SavingsTransaction() { }

    public SavingsTransaction(SavingsAccount savingsAccount, User member, TransactionType type, 
                            BigDecimal amount, BigDecimal balanceBefore, BigDecimal balanceAfter, 
                            String transactionReference) {
        this.savingsAccount = savingsAccount;
        this.member = member;
        this.type = type;
        this.amount = amount;
        this.balanceBefore = balanceBefore;
        this.balanceAfter = balanceAfter;
        this.transactionReference = transactionReference;
    }

    @PrePersist
    private void beforeInsert() {
        transactionDate = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public SavingsAccount getSavingsAccount() { return savingsAccount; }
    public User getMember() { return member; }
    public TransactionType getType() { return type; }
    public BigDecimal getAmount() { return amount; }
    public BigDecimal getBalanceBefore() { return balanceBefore; }
    public BigDecimal getBalanceAfter() { return balanceAfter; }
    public String getTransactionReference() { return transactionReference; }
    public String getCardLastFour() { return cardLastFour; }
    public String getTransactionId() { return transactionId; }
    public LocalDateTime getTransactionDate() { return transactionDate; }
    public String getNotes() { return notes; }

    public String getTransactionDateFormatted() {
        return transactionDate == null ? "" : transactionDate.format(java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy HH:mm"));
    }

    public void setCardLastFour(String cardLastFour) { this.cardLastFour = cardLastFour; }
    public void setTransactionId(String transactionId) { this.transactionId = transactionId; }
    public void setNotes(String notes) { this.notes = notes; }
}