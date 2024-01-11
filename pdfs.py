import PyPDF2


def extract_text(pdf_path):
    with open(pdf_path, 'rb') as f:
        reader = PyPDF2.PdfReader(f)
        for page in reader.pages:
            print(page)
            print(page.extract_text())


if __name__ == '__main__':
    path = '/Users/anjor/datasets/tome.pdf'
    extract_text(path)
