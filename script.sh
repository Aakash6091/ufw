#!/usr/bin/env python3

import sys

# -------------------------------------------------
# 1) Define your bracket data (2024 rates, etc.)
#    You MUST fill in real bracket numbers.
#    Below is just placeholder data!
# -------------------------------------------------

# Example Federal brackets for SINGLE filers (placeholder!)
# Each tuple: (bracket_start, bracket_end, marginal_rate)
federal_brackets_single = [
    (0,       11000,   0.10),
    (11000,   44725,   0.12),
    (44725,   95375,   0.22),
    (95375,   182100,  0.24),
    (182100,  231250,  0.32),
    (231250,  578125,  0.35),
    (578125,  float('inf'), 0.37),
]

# Example State brackets for SINGLE filers (placeholder: Wisconsin!)
# Each tuple: (bracket_start, bracket_end, marginal_rate)
wisconsin_brackets_single = [
    (0,       12960,   0.0354),
    (12960,   25920,   0.0465),
    (25920,   280950,  0.0530),
    (280950,  float('inf'), 0.0765),
]

# FICA rate
FICA_RATE = 0.0765  # 7.65%

# -------------------------------------------------
# 2) Function to compute "marginal bracket" taxes
# -------------------------------------------------
def compute_marginal_tax(income, brackets):
    """
    Given an income and a list of (start, end, rate),
    return the total tax for that bracket structure.
    """
    tax = 0.0
    remaining = income
    for (low, high, rate) in brackets:
        if remaining <= 0:
            break
        # Amount taxed at this bracket
        span = high - low
        taxable = min(remaining, span)
        if taxable < 0:
            taxable = 0
        tax += taxable * rate
        remaining -= taxable
    return tax

# -------------------------------------------------
# 3) Wrapper to compute total tax
#    Federal + State + FICA
# -------------------------------------------------
def compute_total_tax(income, filing_status, state):
    """
    Returns total tax = Fed + State + FICA
    for a given income, filing_status, and state.
    """
    # Choose federal bracket set
    if filing_status.lower() == "single":
        fed_tax = compute_marginal_tax(income, federal_brackets_single)
    else:
        # Extend to 'married_filing_jointly' etc. if needed
        raise ValueError(f"Filing status '{filing_status}' not supported (placeholder).")

    # Choose state bracket set
    if state.lower() == "wisconsin":
        state_tax = compute_marginal_tax(income, wisconsin_brackets_single)
    else:
        # Add other states similarly
        raise ValueError(f"State '{state}' not supported (placeholder).")
    
    fica_tax = income * FICA_RATE
    total = fed_tax + state_tax + fica_tax
    
    # Round to 2 decimals; Python rounds .5 "up"
    return round(total, 2)

# -------------------------------------------------
# 4) Main loop: read lines, parse, compute, output
# -------------------------------------------------
if __name__ == "__main__":
    """
    Example usage:
      echo "1 Single Amy 153979 Wisconsin" | python3 tax_calc.py

    or feed many lines for thousands of forms:
      cat forms.txt | python3 tax_calc.py
    """
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        # Expect input of the form: "Form# Status Name Income State"
        parts = line.split()
        if len(parts) < 5:
            # Adjust if your data format differs
            print("Invalid input line (need 5 fields). Skipping:", line)
            continue
        
        form_number = parts[0]
        filing_status = parts[1]   # e.g. "Single"
        name = parts[2]           # e.g. "Amy"
        income_str = parts[3]     # e.g. "153979"
        state = parts[4]          # e.g. "Wisconsin"
        
        try:
            income = float(income_str)
        except ValueError:
            print("Invalid income value:", income_str)
            continue
        
        total_tax = compute_total_tax(income, filing_status, state)
        
        # Output the result
        print(
            f"Form#: {form_number}, Name: {name}, Income: {income}, "
            f"Status: {filing_status}, State: {state}, "
            f"Total Tax: {total_tax:.2f}"
        )
