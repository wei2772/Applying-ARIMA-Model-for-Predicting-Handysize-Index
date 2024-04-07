
# Seasonal ARIMA
ARIMA 模型，全稱為自我迴歸整合移動平均模型（Autoregressive Integrated Moving Average model），是時間序列預測分析方法之一。ARIMA模型基於一個觀念，即可以僅使用時間序列的過去值來預測其未來值。

ARIMA 模型的主要部分包括：

1.  自我迴歸（AR）部分：這部分表示感興趣的變數是基於其自身滯後（即先前）值的迴歸。在自我迴歸模型 ( AR<sub>(p)</sub> ) 中，我們是基於目標變數歷史數據的組合對目標變數進行預測。 自我迴歸一詞中的自字即表明其是對變數自身進行的迴歸。

    一個 p 階的自回歸模型可以表示如下：

    ![image](https://github.com/wei2772/Applying-ARIMA-Model-for-Predicting-Handysize-Index/assets/166236173/7dbca98e-5d5b-4096-bc7e-2e532ac6b334)

    其中，c 表示常數的截距項；p 代表落後期數；ϕ 代表 y<sub>t</sub> 的係數；ε<sub>t</sub> 表示干擾項。

2.  移動平均（MA）部分：這部分表示迴歸誤差實際上是當前和過去各種時間點的誤差項的線性組合。移動平均模型（MA<sub>(q)</sub>）則使用歷史預測誤差來建立一個類似迴歸的模型。

    ![image](https://github.com/wei2772/Applying-ARIMA-Model-for-Predicting-Handysize-Index/assets/166236173/41f91a6e-4109-4d33-9682-c03deb74be77)

    其中 c 表示常數的截距項；q 代表落後期數；θ 代表 ε<sub>t</sub> 的係數；ε<sub>t</sub> 表示干擾變數
    
3.  整合（I）部分：這部分表示數據值已被替換為它們的值與前一個值的差，這種方法被稱為差分。差分則可以通過去除時間序列中的一些變化特徵來平穩化它的均值，並因此消除（或減小）時間序列的趨勢和季節性。

Seasonal ARIMA 模型在 ARIMA 模型多項式中引入了季節性的項。，通常表示為 ARIMA(p, d, q)(P, D, Q)m，其中 m 表示每個季節的期數，大寫的 P, D, Q 表示 ARIMA 模型季節性部分的自我迴歸、差分和移動平均項。

# dynamic ARIMA
Seasonal ARIMA 僅利用變數的實際觀測值進行建模，卻沒有考慮到隨時間的推移而產生的相關信息的影響。例如，假期、競爭對手活動、法律法規變化或其它外部變數影響。若合理利用此類資訊修整模型，可以得到預測效果更好的時間序列模型。dynamic ARIMA 則是擴展 Seasonal ARIMA 模型，將一些與預測變數相關的資訊納入模型之中。

對包含 ARMA 誤差項的回歸模型進行參數估計時，需要注意的是模型中的所有變數都必須是平穩的。因此，應首先對待預測變數 y<sub>t</sub> 和預測變數  (x<sub>1,t</sub>,...,x<sub>k,t</sub>)做平穩性檢驗。當模型中存在非平穩變數時，我們會對所有變數進行差分。當模型中所有變數都平穩時，我們只需要考慮殘差項的 ARMA 模型的擬合誤差。

有些時候，預測變數對待預測變數的影響不是簡單而迅速的。 例如，投放廣告之後一段時間才會影響銷售接受，而當月的銷售收入會取決於過去幾個月的廣告支出。

在這些情況下，我們需要再模型匯總引入預測變數的滯後項。 假如模型中只有一個預測變數，則假如該預測變數的滯後項之後，滯後模型可寫為：

![image](https://github.com/wei2772/Applying-ARIMA-Model-for-Predicting-Handysize-Index/assets/166236173/646584af-2e91-461c-b0eb-36e662f81cef)

其中， ηt 為 ARIMA 過程。並通過 AICc (訊息準則) 中來選擇滯後期數及 ARIMA 過程中的 p 和 q。

本研究有 5 個預測變數，則須將 5 個預測變數檢定為穩態，再通過 AICc 來判斷個別適合的滯後期數及 ARIMA 模型。

# Applying-ARIMA-Model-for-Predicting-Handysize-Index
本研究採用 Handysize 資料集，資料期間為 2011 年 2 月 ∼ 2023 年 11 月，共 154 筆資料，共 16 項變數。 包含：

“Handysize”：輕便型船運指數

“BSI_t.1”：波羅的海乾散貨指數（BSI）的時間滯後1期

“BHI_t.1”：波羅的海重型指數（BHI）的時間滯後1期

“BCI_t.1”：波羅的海Capesize指數（BCI）的時間滯後1期

“BPI_t.1”：波羅的海Panamax指數（BPI）的時間滯後1期

“Australian.thermal.coal”：澳大利亞熱煤

“Soybeans”：大豆

“Wheat”：小麥

“WTI.crude.Oil”：西德州中級原油（WTI）

“IMF_base.metal.index”：國際貨幣基金組織基本金屬指數

“Corn”：玉米

“CN_metal.production”：中國金屬生產

“Breakbulk.capesize._SeasonIndex”：Capesize散貨船季節指數

“Rock.Phosphate”：磷石

“Iron.Ore”：鐵礦石

“PPI_CN”：中國生產者價格指數

“PPI_US”：美國生產者價格指數


# 特徵工程
1. 資料前處理：將月資料轉換為季資料，實現資料降維。
2. 變數篩選：使用 MARS (多元自適應迴歸模型) 之 GCV （廣義交叉驗證模型選擇準則）排序，生成變數重要性排序。變數重要性排序如下。

![image](https://github.com/wei2772/Applying-ARIMA-Model-for-Predicting-Handysize-Index/assets/166236173/f237cafb-d9c1-450e-a8ca-b754d042e291)

  由上表可以發現，在 Australian.thermal.coal(27.2189) 與 WTI.crude.Oil(9.9866) 有明顯下降趨勢，故將關鍵變數 KPI 設為 BHI_t.1、PPI_US、PPI_CN、Wheat、Australian.thermal.coal 共 5 個。
  
# 結果分析
白噪音檢定：藉由Ljung-Box檢定觀察ARIMA模型的殘差項是否為隨機變動，若檢定結果呈現白噪音（p值 > 0.05），則可以知道ARIMA模型的配適程度良好，可直接做預測。

![image](https://github.com/wei2772/Applying-ARIMA-Model-for-Predicting-Handysize-Index/assets/166236173/aab62337-4cf6-472f-8bbf-b0fede5217a9)
![image](https://github.com/wei2772/Applying-ARIMA-Model-for-Predicting-Handysize-Index/assets/166236173/6d82a160-3ab5-4a4b-908c-fce4a54d95f8)
![image](https://github.com/wei2772/Applying-ARIMA-Model-for-Predicting-Handysize-Index/assets/166236173/6a0bfff3-b994-42b8-824b-46cbfd9806b3)




**評估模型績效**

<p align="center">
  <img src="https://github.com/wei2772/Applying-ARIMA-Model-for-Predicting-Handysize-Index/assets/166236173/5ea57f29-94e3-4fe4-879a-8014d896dfd0" width='60%' height='60%'/>
</p>

三種 ARIMA 模型中，以 dynamic ARIMA considering time lags 之 MAPE = 4.39 表現最好，

Seasonal ARIMA 預測結果

<p align="center">
  <img src="https://github.com/wei2772/Applying-ARIMA-Model-for-Predicting-Handysize-Index/assets/166236173/56a7a596-dcb2-4dfc-8574-13db9ef8f094" width='60%' height='60%'/>
</p>

dynamic ARIMA 預測結果

<p align="center">
  <img src="https://github.com/wei2772/Applying-ARIMA-Model-for-Predicting-Handysize-Index/assets/166236173/a74ea68c-c701-4bc4-8e9a-69241d1dc7d0" width='60%' height='60%'/>
</p>

dynamic ARIMA considering time lags 預測結果

<p align="center">
  <img src="https://github.com/wei2772/Applying-ARIMA-Model-for-Predicting-Handysize-Index/assets/166236173/967f3fd6-3ce5-4ff8-8d02-05acc148f8f9" width='60%' height='60%'/>
</p>

# 結論
本研究採用 Handysize 資料集，以 Seasonal ARIMA、Dynamic ARIMA、Dynamic ARIMA considering time lags 演算法預測輕便型船運指數（Handysize），研究中加入 MARS 篩選變數，並使用 Ljung-Box 白噪聲檢定評估模型績效。以 dynamic ARIMA  considering time lags 之 MAPE = 4.39% 績效最好。





