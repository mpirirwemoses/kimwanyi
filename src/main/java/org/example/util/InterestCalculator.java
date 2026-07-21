package org.example.util;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.Map;

public class InterestCalculator {
    
    public enum InterestType {
        SIMPLE,
        COMPOUND
    }
    
    public enum CalculationPeriod {
        WEEKLY,
        MONTHLY
    }
    
    public static class InterestResult {
        private BigDecimal principal;
        private BigDecimal interestRate;
        private BigDecimal interestAmount;
        private BigDecimal totalAmount;
        private InterestType interestType;
        private int periods;
        private String calculationProcedure;
        
        public InterestResult(BigDecimal principal, BigDecimal interestRate, BigDecimal interestAmount, 
                            BigDecimal totalAmount, InterestType interestType, int periods, String calculationProcedure) {
            this.principal = principal;
            this.interestRate = interestRate;
            this.interestAmount = interestAmount;
            this.totalAmount = totalAmount;
            this.interestType = interestType;
            this.periods = periods;
            this.calculationProcedure = calculationProcedure;
        }
        
        public BigDecimal getPrincipal() { return principal; }
        public BigDecimal getInterestRate() { return interestRate; }
        public BigDecimal getInterestAmount() { return interestAmount; }
        public BigDecimal getTotalAmount() { return totalAmount; }
        public InterestType getInterestType() { return interestType; }
        public int getPeriods() { return periods; }
        public String getCalculationProcedure() { return calculationProcedure; }
    }
    
    public static InterestResult calculateSimpleInterest(BigDecimal principal, BigDecimal annualRate, 
                                                         int periods, CalculationPeriod periodType) {
        BigDecimal periodRate = annualRate.divide(BigDecimal.valueOf(getPeriodsPerYear(periodType)), 4, RoundingMode.HALF_UP)
                                         .divide(new BigDecimal("100"), 4, RoundingMode.HALF_UP);
        
        BigDecimal interest = principal.multiply(periodRate).multiply(new BigDecimal(periods))
                                     .setScale(2, RoundingMode.HALF_UP);
        BigDecimal total = principal.add(interest).setScale(2, RoundingMode.HALF_UP);
        
        StringBuilder procedure = new StringBuilder();
        procedure.append("=== Simple Interest Calculation ===\n\n");
        procedure.append(String.format("Principal (P): KES %,.2f\n", principal));
        procedure.append(String.format("Annual Interest Rate (R): %,.2f%%\n", annualRate));
        procedure.append(String.format("Calculation Period: %s\n", periodType));
        procedure.append(String.format("Number of Periods (T): %d\n\n", periods));
        procedure.append(String.format("Period Rate = Annual Rate / %d / 100\n", getPeriodsPerYear(periodType)));
        procedure.append(String.format("Period Rate = %,.4f / %d / 100 = %,.4f\n\n", annualRate, getPeriodsPerYear(periodType), periodRate));
        procedure.append(String.format("Formula: Interest = P × Period Rate × T\n"));
        procedure.append(String.format("Interest = %,.2f × %,.4f × %d\n", principal, periodRate, periods));
        procedure.append(String.format("Interest = KES %,.2f\n\n", interest));
        procedure.append(String.format("Total Amount = Principal + Interest\n"));
        procedure.append(String.format("Total Amount = %,.2f + %,.2f = KES %,.2f", principal, interest, total));
        
        return new InterestResult(principal, annualRate, interest, total, InterestType.SIMPLE, periods, procedure.toString());
    }
    
    public static InterestResult calculateCompoundInterest(BigDecimal principal, BigDecimal annualRate, 
                                                           int periods, CalculationPeriod periodType) {
        BigDecimal periodRate = annualRate.divide(BigDecimal.valueOf(getPeriodsPerYear(periodType)), 4, RoundingMode.HALF_UP)
                                         .divide(new BigDecimal("100"), 4, RoundingMode.HALF_UP);
        
        BigDecimal compoundFactor = BigDecimal.ONE.add(periodRate).pow(periods);
        BigDecimal total = principal.multiply(compoundFactor).setScale(2, RoundingMode.HALF_UP);
        BigDecimal interest = total.subtract(principal).setScale(2, RoundingMode.HALF_UP);
        
        StringBuilder procedure = new StringBuilder();
        procedure.append("=== Compound Interest Calculation ===\n\n");
        procedure.append(String.format("Principal (P): KES %,.2f\n", principal));
        procedure.append(String.format("Annual Interest Rate (R): %,.2f%%\n", annualRate));
        procedure.append(String.format("Calculation Period: %s\n", periodType));
        procedure.append(String.format("Number of Periods (n): %d\n\n", periods));
        procedure.append(String.format("Period Rate = Annual Rate / %d / 100\n", getPeriodsPerYear(periodType)));
        procedure.append(String.format("Period Rate = %,.4f / %d / 100 = %,.4f\n\n", annualRate, getPeriodsPerYear(periodType), periodRate));
        procedure.append(String.format("Formula: A = P × (1 + r)^n\n"));
        procedure.append(String.format("Where: A = Total Amount, P = Principal, r = Period Rate, n = Periods\n\n"));
        procedure.append(String.format("Total Amount = %,.2f × (1 + %,.4f)^%d\n", principal, periodRate, periods));
        procedure.append(String.format("Total Amount = %,.2f × %,.6f\n", principal, compoundFactor));
        procedure.append(String.format("Total Amount = KES %,.2f\n\n", total));
        procedure.append(String.format("Interest = Total Amount - Principal\n"));
        procedure.append(String.format("Interest = %,.2f - %,.2f = KES %,.2f", total, principal, interest));
        
        return new InterestResult(principal, annualRate, interest, total, InterestType.COMPOUND, periods, procedure.toString());
    }
    
    private static int getPeriodsPerYear(CalculationPeriod periodType) {
        return periodType == CalculationPeriod.WEEKLY ? 52 : 12;
    }
    
    public static int calculatePeriods(LocalDateTime startDate, LocalDateTime endDate, CalculationPeriod periodType) {
        long days = ChronoUnit.DAYS.between(startDate, endDate);
        if (days < 0) return 0;
        
        if (periodType == CalculationPeriod.WEEKLY) {
            return (int) (days / 7);
        } else {
            return (int) (days / 30);
        }
    }
    
    public static boolean shouldCalculateInterest(LocalDateTime lastCalculated, CalculationPeriod periodType) {
        if (lastCalculated == null) return true;
        
        long daysSinceLastCalculation = ChronoUnit.DAYS.between(lastCalculated, LocalDateTime.now());
        
        if (periodType == CalculationPeriod.WEEKLY) {
            return daysSinceLastCalculation >= 7;
        } else {
            return daysSinceLastCalculation >= 30;
        }
    }
}