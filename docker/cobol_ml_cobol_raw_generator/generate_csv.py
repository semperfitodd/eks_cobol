import csv
import random
from datetime import datetime, timedelta
import os


def random_date(start, end):
    delta = end - start
    random_days = random.randint(0, delta.days)
    return start + timedelta(days=random_days)


def generate_transaction():
    transaction_types = {
        'Bank Transaction': ['Account Transfer', 'ATM Withdrawal', 'Check Deposit'],
        'Payroll': ['Salary Payment', 'Bonus Payment', 'Tax Deduction'],
        'Invoice': ['Client Invoice', 'Service Fee', 'Subscription Fee'],
        'Payment': ['Utility Bill', 'Vendor Payment', 'Credit Card Payment']
    }

    transaction_type = random.choice(list(transaction_types.keys()))
    description = random.choice(transaction_types[transaction_type])

    if transaction_type == 'Payroll':
        amount = round(random.uniform(1000, 5000), 2)
    elif transaction_type == 'Invoice':
        amount = round(random.uniform(500, 10000), 2)
    elif transaction_type == 'Payment':
        amount = round(random.uniform(-10000, -100), 2)
    else:
        amount = round(random.uniform(-5000, 5000), 2)

    date = random_date(datetime(2020, 1, 1), datetime(2025, 1, 1)).strftime('%Y-%m-%d')

    return [date, transaction_type, description, amount]


def generate_csv(file_name):
    os.makedirs(os.path.dirname(file_name), exist_ok=True)

    target_size = random.randint(100 * 1024 * 1024, 1024 * 1024 * 1024)

    with open(file_name, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(['Date', 'Transaction Type', 'Description', 'Amount'])

        while os.path.getsize(file_name) < target_size:
            writer.writerow(generate_transaction())

    print(f'CSV file "{file_name}" created successfully with a size of {os.path.getsize(file_name) / (1024 * 1024):.2f} MB!')


if __name__ == '__main__':
    output_directory = '/output/raw-data/'
    current_time = datetime.now().strftime('%Y-%m-%d-%H-%M-%S')
    file_name = os.path.join(output_directory, f'raw-data-{current_time}.csv')

    generate_csv(file_name)
