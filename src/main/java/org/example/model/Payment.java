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
@Table(name = "payments")
public class Payment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = jakarta.persistence.FetchType.LAZY, optional = false)
    @JoinColumn(name = "loan_id", nullable = false)
    private Loan loan;

    @ManyToOne(fetch = jakarta.persistence.FetchType.LAZY, optional = false)
    @JoinColumn(name = "member_id", nullable = false)
    private User member;

    @Column(nullable = false, precision = 14, scale = 2)
    private BigDecimal amount;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private PaymentMethod paymentMethod;

    @Column(length = 100)
    private String cardLastFour;

    @Column(length = 50)
    private String transactionId;

    @Column(nullable = false, updatable = false)
    private LocalDateTime paymentDate;

    @Column(length = 500)
    private String notes;

    protected Payment() { }

    public Payment(Loan loan, User member, BigDecimal amount, PaymentMethod paymentMethod, String transactionId) {
        this.loan = loan;
        this.member = member;
        this.amount = amount;
        this.paymentMethod = paymentMethod;
        this.transactionId = transactionId;
    }

    @PrePersist
    private void beforeInsert() {
        paymentDate = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public Loan getLoan() { return loan; }
    public User getMember() { return member; }
    public BigDecimal getAmount() { return amount; }
    public PaymentMethod getPaymentMethod() { return paymentMethod; }
    public String getCardLastFour() { return cardLastFour; }
    public String getTransactionId() { return transactionId; }
    public LocalDateTime getPaymentDate() { return paymentDate; }
    public String getNotes() { return notes; }

    public void setCardLastFour(String cardLastFour) { this.cardLastFour = cardLastFour; }
    public void setNotes(String notes) { this.notes = notes; }
}