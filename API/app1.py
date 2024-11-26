import numpy as np
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import joblib
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder
from transformers import AutoTokenizer, AutoModelForCausalLM
import uvicorn
import nest_asyncio

nest_asyncio.apply()

# Load heart disease prediction model
model = joblib.load('Logistic_model.pkl')

# Load GPT-2 model for chatbot
tokenizer = AutoTokenizer.from_pretrained("gpt2")
chatbot_model = AutoModelForCausalLM.from_pretrained("gpt2")

# Initialize FastAPI app
app = FastAPI()

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Define input data schema for heart disease prediction
class InputData(BaseModel):
    Age: float
    Sex: int
    ChestPainType: int
    RestingBP: float
    Cholesterol: float
    RestingECG: int
    MaxHR: float
    ExerciseAngina: int
    Oldpeak: float
    ST_Slope: int

class RiskAssessment:
    @staticmethod
    def get_risk_level(prediction_prob, age):
        if age < 50:
            if prediction_prob < 0.025:
                return "Rủi ro thấp"
            elif prediction_prob < 0.075:
                return "Rủi ro trung bình"
            else:
                return "Rủi ro cao"
        elif age < 70:
            if prediction_prob < 0.05:
                return "Rủi ro thấp"
            elif prediction_prob < 0.10:
                return "Rủi ro trung bình"
            else:
                return "Rủi ro cao"
        else:  # age >= 70
            if prediction_prob < 0.075:
                return "Rủi ro thấp"
            elif prediction_prob < 0.15:
                return "Rủi ro trung bình"
            else:
                return "Rủi ro cao"

# Health advice generator based on risk level
def generate_health_advice_from_chatbot(risk_level, data: InputData):
    """
    Generate health advice using the AI model (chatbot) based on the risk level and input data.
    This method will generate a more personalized and detailed health advice.
    """
    advice = []
    
    # Dựa trên mức độ rủi ro
    if risk_level == "Rủi ro cao":
        advice.append("Nguy cơ bệnh tim của bạn rất cao. Bạn nên đi khám bác sĩ ngay lập tức để được tư vấn và kiểm tra.")
    elif risk_level == "Rủi ro trung bình":
        advice.append("Nguy cơ bệnh tim của bạn ở mức trung bình. Hãy duy trì lối sống lành mạnh và kiểm tra sức khỏe định kỳ.")
    elif risk_level == "Rủi ro thấp":
        advice.append("Nguy cơ bệnh tim của bạn thấp. Tiếp tục duy trì thói quen ăn uống lành mạnh và luyện tập thể dục đều đặn.")

    # Kiểm tra chỉ số cholesterol và huyết áp
    if data.Cholesterol > 200:
        advice.append("Chỉ số cholesterol của bạn cao. Hãy hạn chế ăn thực phẩm nhiều cholesterol như thịt đỏ và đồ ăn chiên rán.")
    if data.RestingBP > 140:
        advice.append("Huyết áp của bạn cao. Hãy kiểm tra huyết áp thường xuyên và hạn chế ăn mặn.")
    
    # Các khuyến nghị khác dựa trên các yếu tố khác
    if data.ExerciseAngina == 1:
        advice.append("Bạn có triệu chứng đau ngực khi vận động. Hãy tham khảo ý kiến bác sĩ trước khi tham gia các hoạt động thể chất mạnh.")
    
    # Dùng mô hình chatbot AI để tạo lời khuyên thêm
    prompt = f"""
    Imagine you are a doctor. Based on the following patient information:
    - Heart disease risk level: {risk_level}
    - Cholesterol level: {data.Cholesterol}
    - Blood pressure: {data.RestingBP}
    - Symptoms: Chest pain on exertion: {'Yes' if data.ExerciseAngina == 1 else 'No'}
    
    Please provide three specific and actionable health recommendations to help the patient improve their cardiovascular health.
    """


    # Sử dụng mô hình AI GPT-2 để tạo lời khuyên bổ sung
    ai_advice = ""
    try:
        inputs = tokenizer(prompt, return_tensors="pt", max_length=512, truncation=True)
        outputs = chatbot_model.generate(
            input_ids=inputs.input_ids,
            attention_mask=inputs.attention_mask,
            max_length=400,
            temperature=0.7,
            top_k=50,
            top_p=0.9,
            do_sample=True,
            pad_token_id=tokenizer.eos_token_id,
            no_repeat_ngram_size=2
        )
        ai_advice = tokenizer.decode(outputs[0], skip_special_tokens=True).strip()
    except Exception as e:
        print(f"Lỗi khi gọi mô hình AI: {e}")
    
    if ai_advice:
        advice.append(f"Lời khuyên từ bác sĩ AI: {ai_advice}")
    
    return advice


@app.post("/predict")
def predict_heart_disease(data: InputData):
    try:
        input_data = data.dict()
        
        features = np.array([[input_data['Age'], input_data['Sex'], input_data['ChestPainType'],
                              input_data['RestingBP'], input_data['Cholesterol'], input_data['RestingECG'],
                              input_data['MaxHR'], input_data['ExerciseAngina'], input_data['Oldpeak'],
                              input_data['ST_Slope']]])

        if features.shape[1] != model.n_features_in_:
            raise ValueError(f"Model expects {model.n_features_in_} features, but got {features.shape[1]}")

        prediction = model.predict(features)[0]
        prediction_prob = model.predict_proba(features)[0][1]
        
        risk_level = RiskAssessment.get_risk_level(prediction_prob, input_data['Age'])
        health_advice = generate_health_advice_from_chatbot(risk_level, data)

        result = {
            "prediction": int(prediction),
            "risk_probability": float(prediction_prob),
            "risk_level": risk_level,
            "advice": health_advice
        }
        
        return JSONResponse(content=jsonable_encoder(result))

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/chat")
def chat_with_ai(question: str):
    try:
        # Prepare the input text for GPT-2
        inputs = tokenizer.encode(question, return_tensors="pt", max_length=512, truncation=True)
        
        # Generate response using the GPT-2 model
        outputs = chatbot_model.generate(inputs, max_length=200, num_return_sequences=1, no_repeat_ngram_size=2, temperature=0.7, top_p=0.9, top_k=50)

        # Decode the response and clean it up
        answer = tokenizer.decode(outputs[0], skip_special_tokens=True)

        return JSONResponse(content={"question": question, "answer": answer})

    except Exception as e:
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
    uvicorn.run(app, host="0.0.0.0", port=9000)
