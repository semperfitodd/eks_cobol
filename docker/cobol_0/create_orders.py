import csv
import random
import string

def fixed_width(s, width):
    return s[:width].ljust(width)

first_names = ["John", "Jane", "Mike", "Alice", "Chris", "Karen", "Bob", "Susan", "Steve", "Laura", "Tom", "Mary", "Kevin", "Nancy", "Jason", "Angela", "Brian", "Emily", "Patrick", "Rebecca"]
last_names = ["Smith", "Doe", "Johnson", "Brown", "Green", "Miller", "Wilson", "Clark", "Adams", "Davis", "Harris", "Allen", "Wright", "Hall", "Young", "King", "Scott", "Turner", "Evans", "Moore"]
streets = ["Main St", "Oak Ave", "Elm St", "Pine Rd", "Maple Ln", "Birch Blvd", "Cedar Way", "Spruce Ct", "Ash Dr", "Cherry Cir", "Walnut Pl", "Willow Pkwy", "Redwood Blvd", "Fir Ln", "Hickory Ave", "Chestnut St", "Magnolia Dr", "Cypress Rd", "Juniper Trl", "Sequoia Way"]
items = ["Widget", "Gadget", "Toolset", "Gearbox", "Wrench", "Sawblade", "Drill", "Hammer", "Tape", "Glue", "Level", "BoltSet", "Plier", "Clamp", "Router", "Sander", "Chisel", "BitKit", "HexSet", "Socket"]

with open("input/orders.csv", "w", newline='') as csvfile:
    writer = csv.writer(csvfile)

    for i in range(10000):
        order_id = str(1000 + i)
        customer_name = fixed_width(random.choice(first_names) + " " + random.choice(last_names), 20)
        address = fixed_width(f"{random.randint(100, 999)} {random.choice(streets)}", 20)
        item = fixed_width(random.choice(items), 10)
        amount = str(random.randint(1, 999)).zfill(3)
        frequency = str(random.randint(1, 12)).zfill(2)

        writer.writerow([order_id, customer_name, address, item, amount, frequency])
