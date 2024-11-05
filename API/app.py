import numpy as np
import pandas as pd
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import joblib
import nest_asyncio
import uvicorn
# Add these imports at the top
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder
import json

# Initialize nest_asyncio to allow nested event loops
nest_asyncio.apply()

# Load the model
model = joblib.load('random_forest_model.pkl')

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Add logging middleware
@app.middleware("http")
async def log_requests(request, call_next):
    print(f"Incoming request: {request.method} {request.url}")
    try:
        response = await call_next(request)
        print(f"Response status code: {response.status_code}")
        return response
    except Exception as e:
        print(f"Error processing request: {e}")
        raise

class InputData(BaseModel):
    Age: float
    Sex: int
    ChestPainType: int
    RestingBP: float
    Cholesterol: float
    FastingBS: int
    RestingECG: int
    MaxHR: float
    ExerciseAngina: int
    Oldpeak: float
    ST_Slope: int

import random

class RiskAssessment:
    @staticmethod
    def get_risk_level(prediction_prob):
        if prediction_prob >= 0.75:
            return "Rủi ro rất cao"
        elif prediction_prob >= 0.5:
            return "Rủi ro cao"
        elif prediction_prob >= 0.25:
            return "Rủi ro trung bình"
        else:
            return "Rủi ro thấp"

    @staticmethod
    def get_health_recommendations(input_data, risk_level):
        recommendations = []
        
        # Basic recommendations for everyone (choosing randomly)
        basic_recommendations_pool = [
            "Duy trì chế độ ăn cân bằng, giàu rau xanh và trái cây",
            "Tập thể dục đều đặn, ít nhất 150 phút/tuần",
            "Ngủ đủ giấc (7-8 tiếng/ngày)",
            "Giảm stress thông qua thiền, yoga hoặc các hoạt động thư giãn",
            "Hạn chế đồ uống có cồn và thuốc lá",
            "Uống đủ nước, ít nhất 2 lít mỗi ngày",
            "Thực hiện các bài tập giãn cơ vào buổi sáng để cải thiện lưu thông máu",
            "Thay thế đường bằng các loại ngọt tự nhiên như mật ong hoặc trái cây",
            "Bổ sung các loại hạt như hạnh nhân, óc chó để cung cấp chất béo lành mạnh",
            "Giảm bớt đồ uống có ga và caffein, đặc biệt vào buổi chiều và tối"
        ]
        recommendations.extend(random.sample(basic_recommendations_pool, 4))  # Chọn ngẫu nhiên 4 khuyến nghị

        # Recommendations based on specific indicators (choosing randomly)
        if input_data['RestingBP'] > 130:
            bp_recommendations = [
                "Hạn chế ăn mặn, không quá 5g muối/ngày",
                "Theo dõi huyết áp thường xuyên",
                "Thay thế muối ăn thông thường bằng muối ít natri",
                "Tăng cường tiêu thụ kali từ rau củ như chuối, khoai lang",
                "Tham khảo bác sĩ về việc bổ sung thực phẩm chức năng hỗ trợ huyết áp"
            ]
            recommendations.append(random.choice(bp_recommendations))

        if input_data['Cholesterol'] > 200:
            chol_recommendations = [
                "Hạn chế thực phẩm giàu cholesterol và chất béo bão hòa",
                "Tăng cường ăn các thực phẩm giàu omega-3 như cá hồi, cá ngừ",
                "Sử dụng dầu thực vật thay cho mỡ động vật",
                "Thay thế các loại thịt đỏ bằng cá và gia cầm không da",
                "Bổ sung các loại chất xơ từ ngũ cốc nguyên hạt và rau xanh để hỗ trợ giảm cholesterol"
            ]
            recommendations.append(random.choice(chol_recommendations))

        if input_data['FastingBS'] == 1:
            bs_recommendations = [
                "Kiểm soát đường huyết chặt chẽ",
                "Chia nhỏ bữa ăn trong ngày",
                "Hạn chế đồ ăn ngọt và tinh bột tinh chế",
                "Bổ sung chất xơ từ các loại đậu, rau củ và ngũ cốc nguyên hạt",
                "Tập thể dục nhẹ sau bữa ăn để hỗ trợ tiêu hóa và kiểm soát đường huyết"
            ]
            recommendations.append(random.choice(bs_recommendations))

        if input_data['MaxHR'] > 150:
            hr_recommendations = [
                "Tập thể dục với cường độ vừa phải",
                "Tránh các hoạt động gắng sức quá mức",
                "Thực hiện các bài tập thở sâu để kiểm soát nhịp tim",
                "Tham gia các lớp tập luyện nhẹ nhàng như yoga, pilates",
                "Theo dõi nhịp tim hàng ngày để phát hiện dấu hiệu bất thường kịp thời"
            ]
            recommendations.append(random.choice(hr_recommendations))

        # Additional recommendations for high risk levels
        if risk_level in ["Rủi ro cao", "Rủi ro rất cao"]:
            high_risk_recommendations = [
                "Cần đến gặp bác sĩ để được tư vấn chi tiết",
                "Thực hiện kiểm tra sức khỏe định kỳ 3-6 tháng/lần",
                "Mang theo thuốc cấp cứu khi di chuyển",
                "Học cách nhận biết các dấu hiệu cảnh báo sớm của bệnh tim mạch",
                "Tham gia chương trình phục hồi chức năng tim mạch nếu có điều kiện",
                "Theo dõi cân nặng hàng tuần để kiểm soát các yếu tố nguy cơ liên quan",
                "Tham khảo ý kiến bác sĩ về việc sử dụng thực phẩm chức năng phù hợp",
                "Tham gia các chương trình giáo dục sức khỏe tim mạch để nắm rõ thông tin",
                "Thường xuyên kiểm tra các chỉ số sinh hóa như đường huyết và lipid máu",
                "Chuẩn bị kế hoạch ứng phó khi gặp triệu chứng cấp cứu như khó thở, đau ngực"
            ]
            recommendations.extend(random.sample(high_risk_recommendations, 3))  # Chọn 3 khuyến nghị ngẫu nhiên

        return recommendations


def create_derived_features(data):
    # Create derived features
    if data['Age'] < 40:
        age_group = 0
    elif 40 <= data['Age'] < 50:
        age_group = 1
    elif 50 <= data['Age'] < 60:
        age_group = 2
    else:
        age_group = 3

    if data['MaxHR'] < 100:
        maxhr_category = 0
    elif 100 <= data['MaxHR'] < 140:
        maxhr_category = 1
    elif 140 <= data['MaxHR'] < 180:
        maxhr_category = 2
    else:
        maxhr_category = 3

    if data['RestingBP'] < 120:
        trestbps_group = 0
    elif 120 <= data['RestingBP'] < 140:
        trestbps_group = 1
    else:
        trestbps_group = 2

    if data['Cholesterol'] < 200:
        chol_group = 0
    elif 200 <= data['Cholesterol'] < 240:
        chol_group = 1
    else:
        chol_group = 2

    if data['Oldpeak'] < 1:
        oldpeak_group = 0
    elif 1 <= data['Oldpeak'] < 2:
        oldpeak_group = 1
    else:
        oldpeak_group = 2

    return [age_group, maxhr_category, trestbps_group, chol_group, oldpeak_group]

@app.post("/predict")
def predict_heart_disease(data: InputData):
    try:
        print(f"Received data: {data}")
        input_data = data.dict()
        derived_features = create_derived_features(input_data)

        features = np.array([[
            input_data['Age'], input_data['Sex'], input_data['ChestPainType'],
            input_data['RestingBP'], input_data['Cholesterol'], input_data['FastingBS'],
            input_data['RestingECG'], input_data['MaxHR'], input_data['ExerciseAngina'],
            input_data['Oldpeak'], input_data['ST_Slope']
        ] + derived_features])

        expected_features = model.n_features_in_
        if features.shape[1] != expected_features:
            raise ValueError(f"Model expects {expected_features} features, but got {features.shape[1]}")

        prediction = model.predict(features)[0]
        prediction_prob = model.predict_proba(features)[0][1]
        risk_level = RiskAssessment.get_risk_level(prediction_prob)
        health_recommendations = RiskAssessment.get_health_recommendations(input_data, risk_level)

        result = {
            "prediction": int(prediction),
            "risk_probability": float(prediction_prob),
            "risk_level": risk_level,
            "health_recommendations": health_recommendations
        }
        
        # Ensure proper JSON encoding of Vietnamese characters
        return JSONResponse(
            content=jsonable_encoder(result),
            headers={
                "Content-Type": "application/json; charset=utf-8"
            }
        )
    except Exception as e:
        print(f"Error occurred: {e}")
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/")
def read_root():
    return {"status": "Server is running"}

@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "model_loaded": model is not None,
        "features_expected": model.n_features_in_
    }

if __name__ == "__main__":
    print(f"Model expects {model.n_features_in_} features")
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")