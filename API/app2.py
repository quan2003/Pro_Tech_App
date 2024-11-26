from transformers import AutoTokenizer, AutoModelForCausalLM
import numpy as np
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from fastapi.responses import JSONResponse
import joblib
import uvicorn
import nest_asyncio

# Sử dụng nest_asyncio để chạy FastAPI trong môi trường tương thích
nest_asyncio.apply()

# Load mô hình XGBoost để dự đoán nguy cơ bệnh tim
try:
    model = joblib.load('xgboost_model.pkl')  # Đường dẫn đến mô hình XGBoost
except FileNotFoundError:
    print("Không tìm thấy mô hình XGBoost.")
    model = None

# Load mô hình ngôn ngữ GPT-2
try:
    tokenizer = AutoTokenizer.from_pretrained("gpt2")
    model_turku = AutoModelForCausalLM.from_pretrained("gpt2")
except Exception as e:
    tokenizer, model_turku = None, None
    print(f"Lỗi khi tải mô hình GPT-2: {e}")

# Khởi tạo ứng dụng FastAPI
app = FastAPI()

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# Định nghĩa dữ liệu đầu vào cho dự đoán
class InputData(BaseModel):
    BMI: float
    Smoking: int
    AlcoholDrinking: int
    Stroke: int
    PhysicalHealth: float
    MentalHealth: float
    DiffWalking: int
    Sex: int
    AgeCategory: int
    Race: int
    Diabetic: int
    PhysicalActivity: int
    GenHealth: int
    SleepTime: float
    Asthma: int
    KidneyDisease: int
    SkinCancer: int
def generate_risk_based_advice(risk_level, data: InputData):
    """
    Generate health advice based on risk level and user data.
    """
    advice = []

    # Fallback logic if risk_level or data is invalid
    if not risk_level or not isinstance(data, InputData):
        return [
            "Không thể phân tích rủi ro sức khỏe. Hãy duy trì chế độ ăn uống lành mạnh, tập thể dục đều đặn, và kiểm tra sức khỏe định kỳ."
        ]

    # Risk-based advice
    if risk_level == "Rủi ro rất cao":
        advice.append("Bạn có nguy cơ sức khỏe rất cao. Hãy đến gặp bác sĩ và tuân thủ nghiêm ngặt các lời khuyên y tế.")
    elif risk_level == "Rủi ro cao":
        advice.append("Bạn có nguy cơ cao. Hãy duy trì lối sống lành mạnh và kiểm tra sức khỏe định kỳ.")
    elif risk_level == "Rủi ro trung bình":
        advice.append("Nguy cơ sức khỏe của bạn ở mức trung bình. Hãy duy trì lối sống lành mạnh để cải thiện sức khỏe.")
    elif risk_level == "Rủi ro thấp":
        advice.append("Nguy cơ sức khỏe của bạn thấp. Hãy tiếp tục duy trì lối sống tích cực và lành mạnh.")

    # BMI
    if data.BMI >= 25:
        advice.append("Bạn có chỉ số BMI cao. Hãy cân nhắc chế độ ăn uống lành mạnh và tập thể dục thường xuyên.")
    elif data.BMI < 18.5:
        advice.append("Bạn có chỉ số BMI thấp. Hãy đảm bảo ăn uống đủ dinh dưỡng để cải thiện cân nặng.")

    # Smoking
    if data.Smoking == 1:
        advice.append("Hút thuốc lá có thể gây nguy hiểm cho sức khỏe tim mạch. Hãy cố gắng bỏ thuốc lá.")
    else:
        advice.append("Tốt! Bạn không hút thuốc lá, hãy tiếp tục duy trì thói quen này.")

    # Alcohol Drinking
    if data.AlcoholDrinking == 1:
        advice.append("Hạn chế uống rượu bia để bảo vệ gan và hệ thần kinh.")
    else:
        advice.append("Tốt! Bạn không uống rượu bia, điều này rất tốt cho sức khỏe.")

    # Physical and Mental Health
    if data.PhysicalHealth < 15:
        advice.append("Hãy duy trì các bài tập nhẹ nhàng để cải thiện sức khỏe thể chất.")
    else:
        advice.append("Bạn đang có sức khỏe thể chất tốt. Hãy duy trì lối sống lành mạnh!")

    if data.MentalHealth < 15:
        advice.append("Hãy tham gia các hoạt động thư giãn để cải thiện sức khỏe tinh thần.")
    else:
        advice.append("Sức khỏe tinh thần của bạn rất ổn định. Tiếp tục duy trì các hoạt động tích cực!")

    # Sleep Time
    if data.SleepTime < 7:
        advice.append("Hãy cố gắng ngủ đủ 7-8 tiếng mỗi ngày để cơ thể được nghỉ ngơi đầy đủ.")
    elif data.SleepTime > 9:
        advice.append("Ngủ quá nhiều cũng không tốt. Hãy cố gắng duy trì giấc ngủ từ 7-9 tiếng mỗi ngày.")

    # Chronic Conditions
    if data.KidneyDisease == 1:
        advice.append("Bạn có nguy cơ về bệnh thận. Hãy kiểm tra sức khỏe định kỳ và hạn chế ăn muối.")
    if data.SkinCancer == 1:
        advice.append("Bảo vệ da khi ra nắng và theo dõi các triệu chứng bất thường trên da.")
    if data.Asthma == 1:
        advice.append("Bạn có nguy cơ bị hen suyễn. Tránh các yếu tố kích ứng như bụi và ô nhiễm không khí.")

    # Diabetic
    if data.Diabetic == 1:
        advice.append("Bạn có nguy cơ bị tiểu đường. Hãy hạn chế đường và kiểm tra sức khỏe định kỳ.")

    # Physical Activity
    if data.PhysicalActivity == 0:
        advice.append("Hãy cố gắng tham gia các hoạt động thể chất hàng ngày như đi bộ hoặc tập yoga.")
    else:
        advice.append("Tốt! Bạn đang duy trì thói quen tập thể dục. Hãy tiếp tục!")

    # General Health
    if data.GenHealth == 0:
        advice.append("Tình trạng sức khỏe của bạn yếu. Hãy đi khám sức khỏe và duy trì chế độ sống lành mạnh.")
    elif data.GenHealth == 4:
        advice.append("Tình trạng sức khỏe của bạn rất tốt. Hãy duy trì chế độ sống hiện tại!")

    # Nếu không có lời khuyên, trả về mặc định
    if not advice:
        return [
            "Không thể phân tích rủi ro sức khỏe. Hãy duy trì chế độ ăn uống lành mạnh, tập thể dục đều đặn, và kiểm tra sức khỏe định kỳ."
        ]

    return advice

@app.post("/predict")
def predict(data: InputData):
    """
    Predict risk level and provide health advice.
    """
    try:
        # Chuẩn bị dữ liệu đầu vào cho XGBoost
        features = np.array([[  
            data.BMI, data.Smoking, data.AlcoholDrinking, data.Stroke, data.PhysicalHealth,
            data.MentalHealth, data.DiffWalking, data.Sex, data.AgeCategory, data.Race,
            data.Diabetic, data.PhysicalActivity, data.GenHealth, data.SleepTime,
            data.Asthma, data.KidneyDisease, data.SkinCancer
        ]])
        prediction = int(model.predict(features)[0])
        prediction_prob = float(model.predict_proba(features)[0][1])

        # Phân loại mức độ rủi ro
        if prediction_prob >= 0.8:
            risk_level = "Rủi ro rất cao"
        elif prediction_prob >= 0.6:
            risk_level = "Rủi ro cao"
        elif prediction_prob >= 0.45:
            risk_level = "Rủi ro trung bình"
        else:
            risk_level = "Rủi ro thấp"

        # Tạo prompt ngắn gọn để sinh lời khuyên
        prompt = f"""
       Provide three actionable health recommendations:
        1. A healthy diet plan tailored for a BMI of {data.BMI}.
        2. Lifestyle habits for {data.PhysicalHealth} days of physical health instability and {data.MentalHealth} days of mental instability.
        3. Physical exercises suitable for someone with a BMI of {data.BMI}.
        Ensure advice is practical, specific, and concise.
        """

        # Gọi mô hình ngôn ngữ để sinh lời khuyên
        ai_advice = ""
        if model_turku:
            try:
                inputs = tokenizer(prompt, return_tensors="pt", max_length=512, truncation=True)
                outputs = model_turku.generate(
                    input_ids=inputs.input_ids,
                    attention_mask=inputs.attention_mask,  # Sửa lỗi thiếu attention_mask
                    max_length=400,
                    temperature=0.7,
                    top_k=50,
                    top_p=0.9,
                    do_sample=True,
                    pad_token_id=tokenizer.eos_token_id,  # Đặt rõ pad_token_id
                    no_repeat_ngram_size=2
                )
                ai_advice = tokenizer.decode(outputs[0], skip_special_tokens=True).strip()
            except Exception as e:
                print(f"Lỗi khi gọi mô hình AI: {e}")

        # Fallback: Nếu AI không trả về lời khuyên hợp lệ
        if not ai_advice or len(ai_advice) < 50 or "1." not in ai_advice:
            ai_advice = "\n".join(generate_risk_based_advice(risk_level, data))

        # Làm sạch kết quả đầu ra
        cleaned_advice = []
        for line in ai_advice.split("\n"):
            line = line.strip()
            if len(line) > 0 and not line.lower().startswith("provide") and len(line.split()) > 2:
                cleaned_advice.append(line)
        ai_advice = "\n".join(cleaned_advice)

        # Trả kết quả
        return JSONResponse(content={
            "risk_level": risk_level,
            "risk_probability": round(prediction_prob * 100, 2),
            "advice": ai_advice,
        })

    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Lỗi trong quá trình xử lý: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app,
        host="0.0.0.0",  # Thay đổi từ 127.0.0.1 thành 0.0.0.0
        port=8000,
        reload=True,
        log_level="debug"
    )