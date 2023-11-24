import csv
from faker import Faker
import random
from datetime import date, timedelta

fake = Faker()

#### Creates random data for the user table ####
def generate_user_data(num_rows):
    data = []
    for _ in range(num_rows):
        user_data = {
            'username': fake.user_name(),
            'first_name': fake.first_name(),
            'last_name': fake.last_name(),
            'password': fake.password(),
            'type': random.choice(['personal', 'business']),
            'email': fake.email(),
            'age': random.randint(18, 99),
            'date_of_birth': fake.date_of_birth(minimum_age=18, maximum_age=99),
            'state': fake.state_abbr(),
            'phone_number': fake.phone_number(),
            'pin': random.randint(0000, 9999)
        }
        data.append(user_data)
    return data

def write_to_csv(data, filename):
    with open(filename, 'w', newline='') as csvfile:
        fieldnames = data[0].keys()
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(data)

if __name__ == "__main__":
    num_rows = 10000  # Adjust the number of rows as needed
    output_filename = 'user_data.csv'

    user_data = generate_user_data(num_rows)
    write_to_csv(user_data, output_filename)

    print(f'{num_rows} rows of user data written to {output_filename}')
