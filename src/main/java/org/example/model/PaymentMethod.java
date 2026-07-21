package org.example.model;

public enum PaymentMethod {
    CARD,
    MPESA,
    BANK_TRANSFER,
    CASH;

    public static PaymentMethod fromString(String value) {
        if (value == null || value.trim().isEmpty()) {
            return MPESA;
        }
        try {
            return PaymentMethod.valueOf(value.trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            return MPESA;
        }
    }
}
