# GTM Server-Side Personalization Templates

This project provides a **GTM Client Template** and a **GTM Tag Template** to enable advanced use cases like real-time personalization using Google Tag Manager Server-Side and Firestore.  

[full article link](https://www.linkedin.com/pulse/empowering-personalization-gtm-server-side-firestore-mathias-berger-nzwxe/)

## 🚀 Features  

### Client Template  
- **Claim Requests:** Activate response headers to process incoming POST requests.  
- **Path Configuration:** Customize the endpoint path to handle specific events.  
- **Response Handling:** Ensure the appropriate response is returned to the GTM environment for subsequent actions.  

### Tag Template  
- **Firestore Integration:** Read/write data directly to a Firestore collection and document.  
- **Event Filtering:** Whitelist specific events to control Firestore interactions.  
- **Custom Data Shaping:** Define fields and structures for the data stored or retrieved.  
- **Response Activation:** Enable and shape the response payload for personalized use cases.  

---

## 💡 Use Cases  

- **Real-Time Personalization:** Return customized recommendations, or user-specific content across devices.  
- **Data Synchronization:** Store user interaction data for consistent experiences across web and app platforms.  
- **Advanced Analytics:** Collect and process granular event-level data for deeper insights.  

---

## 📖 Getting Started  

### 1️⃣ Install the Client Template  
1. Download or clone the client template file from this repository.  
2. Import it into your GTM Server-Side container.  
3. Configure the **path** to handle requests (e.g., `/api/personalization`).  

### 2️⃣ Set Up the Firestore Collection  
1. Navigate to your GCP Firestore database: [Firestore Console](https://console.cloud.google.com/firestore/databases).  
2. Create a collection (e.g., `UserActivity`).  

### 3️⃣ Configure the Tag Template  
1. Import the tag template into your GTM Server-Side container.  
2. Add your Firestore **Collection ID** and specify the **Document Name** for user-centric data.  
3. Define the fields and structure of the data to be stored or retrieved.  
4. Activate response handling and configure events to interact with Firestore.  

---

## 📝 Template Features Overview  

| Feature                   | Client Template       | Tag Template           |  
|---------------------------|-----------------------|-------------------------|  
| Custom Path Handling      | ✅                    | -                       |  
| Firestore Integration     | -                     | ✅                      |  
| Event Whitelisting        | -                     | ✅                      |  
| Data Shaping              | -                     | ✅                      |  
| Response Activation       | ✅                    | ✅                      |  

---

## 📄 License  

This project is licensed under the [Apache License 2.0](LICENSE).  
