import os
import requests

PROMPT = """You are an AI assistant that analyzes customer order data and provides insights.

Task: Process the input orders and enrich them with:
1. Customer Category
2. Personalized Recommendation

Categorization Rules:
- VIP Customer: 
  * Total spend over 50 units
  * Order frequency of 5 or more
  * Offer a 10% discount

- Standard Customer:
  * Total spend between 10-50 units
  * Order frequency between 2-4
  * No special offer

- New Customer:
  * Total spend less than 10 units
  * Order frequency of 1
  * Suggest an upsell to a different product

Input Format:
Order: [Order Number] | [Customer Name] | [Address] | [Product] | [Quantity] | Frequency: [Order Frequency]

Output Format:
Order: [Original Order Details] | Category: [Customer Category] | [Optional Recommendation]

Please process the following orders:
"""

def read_input_file(filepath):
    with open(filepath, 'r') as f:
        return f.read().strip()

def process_with_llm(input_text):
    url = "http://deepseek-service.deepseek.svc.cluster.local:11434/api/generate"
    payload = {
        "model": "deepseek-r1:7b",
        "prompt": PROMPT + input_text,
        "stream": False,
    }
    headers = {"Content-Type": "application/json"}
    response = requests.post(url, json=payload, headers=headers)
    if response.status_code == 200:
        return response.json().get("response", "")
    else:
        raise Exception(f"LLM request failed with status {response.status_code}: {response.text}")

def main():
    input_file = os.environ.get("TRANSFORMED_FILE", "/mnt/efs/output/transformed_orders.txt")
    output_file = os.environ.get("LLM_TRANSFORMED_FILE", "/mnt/efs/output/llm_transformed_orders.txt")

    input_text = read_input_file(input_file)
    llm_response = process_with_llm(input_text)

    with open(output_file, 'w') as f:
        f.write(llm_response)

    print(f"Processed orders saved to {output_file}")

if __name__ == "__main__":
    main()