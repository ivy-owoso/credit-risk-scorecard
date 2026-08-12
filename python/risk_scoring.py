import mysql.connector
import pandas as pd
import numpy as np
from sklearn.preprocessing import MinMaxScaler

conn = mysql.connector.connect(
    host="localhost", user="root",
    password="Pmnp!4242", database="credit_risk"
)

df = pd.read_sql("SELECT * FROM company_ratios", conn)
conn.close()

df['debt_to_equity_inv'] = 1 / df['debt_to_equity']

score_columns = ['debt_to_equity_inv', 'current_ratio', 'interest_coverage', 'altman_z_score']
df_filled = df[score_columns].fillna(df[score_columns].mean())

scaler = MinMaxScaler()
scaled = pd.DataFrame(scaler.fit_transform(df_filled), columns=score_columns)

weights = {'debt_to_equity_inv': 0.3, 'current_ratio': 0.2,
           'interest_coverage': 0.2, 'altman_z_score': 0.3}

df['risk_score'] = sum(scaled[col] * w for col, w in weights.items())
df['risk_category'] = pd.qcut(df['risk_score'], q=3, labels=['High Risk', 'Medium Risk', 'Low Risk'])

import numpy as np

trends = []
for company, group in df.groupby('company'):
    group = group.sort_values('year')
    slope = np.polyfit(group['year'], group['risk_score'], 1)[0] if len(group) >= 2 else None
    trends.append({'company': company, 'trend_slope': slope})

trend_df = pd.DataFrame(trends)

df.to_csv('risk_scores_output.csv', index=False)
print(df[['company', 'year', 'risk_score', 'risk_category']])
print(trend_df)
