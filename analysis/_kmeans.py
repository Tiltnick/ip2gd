from sklearn.cluster import KMeans
import numpy as np
from skLearn.preprocessing import MinMaxScaler
from matplotlib import pyplot as plt

df = pd.read_csv("data.csv")
df.head()

plt.scatter(df.x, df.y)
plt.xlabel("X")
plt.ylabel("Y")
plt.title("Data Points")
plt.show()

km = KMeans(n_clusters=3)
x_predicted = km.fit_predict(df[["x", "y"]])
x_predicted

df["cluster"] = y_predicted
df.head()

df1 = df[df.cluster == 0]
df2 = df[df.cluster == 1]
df3 = df[df.cluster == 2]

plt.scatter(df1.x, df1.y, color="red")
plt.scatter(df2.x, df2.y, color="blue")
plt.scatter(df3.x, df3.y, color="green")

plt.xlabel("X")
plt.ylabel("Y")
plt.title("K-Means Clustering")
plt.legend()