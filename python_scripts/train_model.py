# python_scripts/train_model.py
import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
import firebase_admin
from firebase_admin import credentials, firestore
import os

# Use relative path to the service account key
script_dir = os.path.dirname(os.path.abspath(__file__))
cred_path = os.path.join(script_dir, '../keys/serviceAccountKey.json')
cred = credentials.Certificate(cred_path)
firebase_admin.initialize_app(cred)
db = firestore.client()

# Fetch data
docs = db.collection('listings').get()
data = []
for doc in docs:
    listing = doc.to_dict()
    if all(k in listing for k in ['rent', 'bedrooms', 'bathrooms', 'addressonmap']):
        data.append({
            'rent': float(listing['rent']),
            'bedrooms': listing['bedrooms'],
            'bathrooms': listing['bathrooms'],
            'latitude': listing['addressonmap']['latitude'],
            'longitude': listing['addressonmap']['longitude']
        })

df = pd.DataFrame(data)

# Prepare features and target
X = df[['bedrooms', 'bathrooms', 'latitude', 'longitude']]
y = df['rent']

# Split data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train model
model = LinearRegression()
model.fit(X_train, y_train)

# Print coefficients for verification
print('Coefficients:', model.coef_)
print('Intercept:', model.intercept_)
print('R² Score:', model.score(X_test, y_test))

# Save coefficients to Firestore
db.collection('models').document('rent_predictor').set({
    'coefficients': model.coef_.tolist(),
    'intercept': float(model.intercept_),
    'last_updated': firestore.SERVER_TIMESTAMP
})