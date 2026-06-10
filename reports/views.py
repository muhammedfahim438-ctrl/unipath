from django.http import HttpResponse
from .csv_report import generate_csv_report  # import our function


def download_csv(request):
    try:
        # Call our function to generate the CSV
        csv_content = generate_csv_report()

        # Create an HTTP response with CSV content type
        response = HttpResponse(csv_content, content_type='text/csv')

        # This line tells the browser to download the file
        response['Content-Disposition'] = 'attachment; filename="learning_style_report.csv"'

        return response

    except FileNotFoundError:
        # If serviceAccountKey.json is missing
        return HttpResponse(
            "Error: serviceAccountKey.json not found. Get it from Fahim!",
            status=500
        )

    except Exception as e:
        # Any other error
        return HttpResponse(f"Error generating CSV: {str(e)}", status=500)