import boto3
import csv
import sys

def fetch_inspector_findings(instance_id):
    # Specify your region here
    region = 'us-east-1'

    client = boto3.client('inspector2', region_name=region)

    findings = []
    paginator = client.get_paginator('list_findings')

    # Filter by resource ID (which is the instance ID in this case)
    filter_criteria = {
        'resourceId': [
            {
                'comparison': 'EQUALS',
                'value': instance_id
            }
        ]
    }

    # Fetch findings using pagination with the correct filter
    for page in paginator.paginate(filterCriteria=filter_criteria):
        for finding in page['findings']:
            findings.append(finding)

    # Debug: Print the findings to verify data is fetched
    print(f"Findings for instance {instance_id}:")
    print(findings)

    if not findings:
        print(f"No findings found for instance {instance_id}.")
        return

    filename = f"{instance_id}.csv"

    with open(filename, 'w', newline='') as csvfile:
        fieldnames = ['S.NO', 'Severity', 'Title', 'Package Manager']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()

        serial_number = 1  # Initialize serial number

        for finding in findings:
            severity = finding.get('severity', 'N/A')
            title = finding.get('title', 'N/A')

            # Handle vulnerable packages
            vulnerable_packages = finding.get('packageVulnerabilityDetails', {}).get('vulnerablePackages', [])

            if vulnerable_packages:
                for package in vulnerable_packages:
                    package_manager = package.get('packageManager', 'N/A')  # Get package manager
                    writer.writerow({
                        'S.NO': serial_number,
                        'Severity': severity,
                        'Title': f"{title} - {package.get('name', 'N/A')}",
                        'Package Manager': package_manager  # Fetch package manager automatically
                    })
                    serial_number += 1  # Increment serial number for each package
            else:
                # If no vulnerable packages, still log the finding
                writer.writerow({
                    'S.NO': serial_number,
                    'Severity': severity,
                    'Title': title,
                    'Package Manager': 'N/A'
                })
                serial_number += 1  # Increment for the finding without packages

    print(f"Results saved to {filename}")

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python fetch_inspector_findings.py <instance_id>")
        sys.exit(1)

    instance_id = sys.argv[1]
    fetch_inspector_findings(instance_id)
