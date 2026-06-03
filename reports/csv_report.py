# This file reads Firebase Firestore data and generates a CSV report

import csv
import io
import firebase_admin
from firebase_admin import credentials, firestore

def initialize_firebase():
    # Only initialize Firebase once — if already done, skip it
    if not firebase_admin._apps:
        # Load the secret key file Fahim gave you
        cred = credentials.Certificate('serviceAccountKey.json')
        firebase_admin.initialize_app(cred)

def generate_csv_report():
    # Step 1 — initialize Firebase connection
    initialize_firebase()

    # Step 2 — connect to Firestore database
    db = firestore.client()

    # Step 3 — read all documents from learning_style_results collection
    results = db.collection('learning_style_results').stream()

    # Step 4 — create a CSV file in memory (no need to save on disk)
    output = io.StringIO()

    # Step 5 — define the column headers for the CSV
    fieldnames = [
        'Student Name',
        'Department',
        'Year',
        'Visual Score',
        'Auditory Score',
        'Kinesthetic Score',
        'Dominant Style',
        'Date'
    ]

    # Step 6 — create CSV writer
    writer = csv.DictWriter(output, fieldnames=fieldnames)

    # Step 7 — write the header row first
    writer.writeheader()

    # Step 8 — loop through each student document in Firestore
    for doc in results:
        # Get all fields from this document
        data = doc.to_dict()

        # Get individual scores
        visual = data.get('visual_score', 0)
        auditory = data.get('auditory_score', 0)
        kinesthetic = data.get('kinesthetic_score', 0)

        # Find which style has the highest score
        scores = {
            'Visual': visual,
            'Auditory': auditory,
            'Kinesthetic': kinesthetic
        }
        # max() finds the key with the biggest value
        dominant_style = max(scores, key=scores.get)

        # Write one row for this student
        writer.writerow({
            'Student Name': data.get('name', 'Unknown'),
            'Department': data.get('department', 'Unknown'),
            'Year': data.get('year', 'Unknown'),
            'Visual Score': visual,
            'Auditory Score': auditory,
            'Kinesthetic Score': kinesthetic,
            'Dominant Style': dominant_style,
            'Date': data.get('date', 'Unknown')
        })

    # Step 9 — return the CSV content as a string
    output.seek(0)
    return output.getvalue()