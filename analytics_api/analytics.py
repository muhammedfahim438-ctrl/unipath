# This file reads Firebase data and calculates all analytics stats

import firebase_admin
from firebase_admin import credentials, firestore


def initialize_firebase():
    # Only initialize Firebase once — if already done, skip it
    if not firebase_admin._apps:
        cred = credentials.Certificate('serviceAccountKey.json')
        firebase_admin.initialize_app(cred)


def get_analytics_data():
    # Step 1 — initialize Firebase
    initialize_firebase()

    # Step 2 — connect to Firestore
    db = firestore.client()

    # ─── STUDENTS DATA ───────────────────────────────────────

    # Step 3 — read all students from Firestore
    students_ref = db.collection('students').stream()

    # Step 4 — count students and group by department
    total_students = 0
    department_wise = {}  # empty dictionary to store dept counts

    for student in students_ref:
        data = student.to_dict()
        total_students += 1  # count each student

        # Get department name
        dept = data.get('department', 'Unknown')

        # If department already in dict, add 1 — else start at 1
        if dept in department_wise:
            department_wise[dept] += 1
        else:
            department_wise[dept] = 1

    # ─── APPOINTMENTS DATA ───────────────────────────────────

    # Step 5 — read all appointments from Firestore
    appointments_ref = db.collection('appointments').stream()

    # Step 6 — count appointments by status
    total_appointments = 0
    completed_sessions = 0
    pending_sessions = 0

    for appointment in appointments_ref:
        data = appointment.to_dict()
        total_appointments += 1  # count each appointment

        # Get status field
        status = data.get('status', '').lower()

        # Count based on status
        if status == 'completed':
            completed_sessions += 1
        elif status == 'pending':
            pending_sessions += 1

    # ─── PERFORMANCE CALCULATION ─────────────────────────────

    # Step 7 — calculate performance percentages
    # Based on completed sessions vs total appointments
    if total_appointments > 0:
        completion_rate = (completed_sessions / total_appointments) * 100
    else:
        completion_rate = 0

    # Assign performance distribution based on completion rate
    if completion_rate >= 80:
        performance = {
            "Excellent": 40,
            "Good": 30,
            "Average": 20,
            "Poor": 10
        }
    elif completion_rate >= 60:
        performance = {
            "Excellent": 25,
            "Good": 35,
            "Average": 30,
            "Poor": 10
        }
    elif completion_rate >= 40:
        performance = {
            "Excellent": 15,
            "Good": 25,
            "Average": 40,
            "Poor": 20
        }
    else:
        performance = {
            "Excellent": 10,
            "Good": 20,
            "Average": 30,
            "Poor": 40
        }

    # ─── RETURN ALL DATA ─────────────────────────────────────

    # Step 8 — return everything as a dictionary
    return {
        "total_students": total_students,
        "total_appointments": total_appointments,
        "completed_sessions": completed_sessions,
        "pending_sessions": pending_sessions,
        "department_wise": department_wise,
        "performance": performance
    }