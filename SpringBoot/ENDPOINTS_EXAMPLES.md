# SpringBoot API Endpoints Examples

This document contains request and response examples for all API endpoints.

---

## Video Cataleg Endpoints

Base URL: `/Cataleg`

### 1. GET /Cataleg/

**Description:** Get welcome message

**Method:** GET  
**Authentication:** None  
**Response Status:** 200 OK

**Response:**
```
Benvinguts al Cataleg
```

---

### 2. GET /Cataleg

**Description:** Get all videos from catalog

**Method:** GET  
**Authentication:** Required (JWT Token)  
**Response Status:** 200 OK

**Response:**
```json
[
  {
    "id": 1,
    "title": "Introduction to Java",
    "description": "A comprehensive guide to Java programming",
    "category": [
      {
        "id": 1
      },
      {
        "id": 2
      }
    ],
    "study": {
      "id": 1
    },
    "rating": 4.5,
    "season": 1,
    "series": {
      "id": 1
    },
    "chapter": 1,
    "duration": 45,
    "codec": "H.264",
    "resolucio": "1920x1080",
    "pes": 500000000
  },
  {
    "id": 2,
    "title": "Advanced Spring Boot",
    "description": "Deep dive into Spring Boot framework",
    "category": [
      {
        "id": 3
      }
    ],
    "study": {
      "id": 2
    },
    "rating": 4.8,
    "season": 2,
    "series": {
      "id": 2
    },
    "chapter": 5,
    "duration": 60,
    "codec": "H.265",
    "resolucio": "3840x2160",
    "pes": 1000000000
  }
]
```

---

### 3. GET /Cataleg/{id}

**Description:** Get a specific video by ID

**Method:** GET  
**Authentication:** None  
**Path Parameters:**
- `id` (Long): Video ID

**Response Status:** 200 OK

**Example Request:**
```
GET /Cataleg/1
```

**Response:**
```json
{
  "id": 1,
  "title": "Introduction to Java",
  "description": "A comprehensive guide to Java programming",
  "category": [
    {
      "id": 1
    },
    {
      "id": 2
    }
  ],
  "study": {
    "id": 1
  },
  "rating": 4.5,
  "season": 1,
  "series": {
    "id": 1
  },
  "chapter": 1,
  "duration": 45,
  "codec": "H.264",
  "resolucio": "1920x1080",
  "pes": 500000000
}
```

---

### 4. POST /Cataleg

**Description:** Create a new video in the catalog

**Method:** POST  
**Authentication:** Required (JWT Token with admin claims)  
**Request Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body:**
```json
{
  "title": "Web Development Fundamentals",
  "description": "Learn the basics of web development",
  "category": [
    {
      "id": 1
    },
    {
      "id": 4
    }
  ],
  "study": {
    "id": 1
  },
  "rating": 4.2,
  "season": 1,
  "series": {
    "id": 3
  },
  "chapter": 1,
  "duration": 50,
  "codec": "H.264",
  "resolucio": "1920x1080",
  "pes": 600000000
}
```

**Response Status:** 201 Created

**Response:** Empty body

---

### 5. PUT /Cataleg/{id}

**Description:** Update an existing video

**Method:** PUT  
**Authentication:** Required (JWT Token with admin claims)  
**Path Parameters:**
- `id` (Long): Video ID to update

**Request Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body:**
```json
{
  "title": "Web Development Advanced",
  "description": "Advanced topics in web development",
  "category": [
    {
      "id": 1
    },
    {
      "id": 4
    },
    {
      "id": 5
    }
  ],
  "study": {
    "id": 2
  },
  "rating": 4.7,
  "season": 2,
  "series": {
    "id": 3
  },
  "chapter": 2,
  "duration": 65,
  "codec": "H.265",
  "resolucio": "2560x1440",
  "pes": 750000000
}
```

**Response Status:** 200 OK or 404 Not Found

**Response:** Empty body

---

### 6. DELETE /Cataleg/{id}

**Description:** Delete a video from the catalog

**Method:** DELETE  
**Authentication:** Required (JWT Token with admin claims)  
**Path Parameters:**
- `id` (Long): Video ID to delete

**Request Headers:**
```
Authorization: Bearer <JWT_TOKEN>
```

**Response Status:** 204 No Content

**Response:** Empty body

---

## Category Endpoints

Base URL: `/Category`

### 1. GET /Category

**Description:** Get all categories

**Method:** GET  
**Authentication:** None  
**Response Status:** 200 OK

**Response:**
```json
[
  {
    "id": 1,
    "name": "Programming"
  },
  {
    "id": 2,
    "name": "Web Development"
  },
  {
    "id": 3,
    "name": "Mobile Development"
  },
  {
    "id": 4,
    "name": "Data Science"
  }
]
```

---

### 2. GET /Category/{id}

**Description:** Get a specific category by ID

**Method:** GET  
**Authentication:** None  
**Path Parameters:**
- `id` (Long): Category ID

**Response Status:** 200 OK

**Example Request:**
```
GET /Category/1
```

**Response:**
```json
{
  "id": 1,
  "name": "Programming"
}
```

---

### 3. POST /Category

**Description:** Create a new category

**Method:** POST  
**Authentication:** Required (JWT Token with admin claims)  
**Request Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "Databases"
}
```

**Response Status:** 201 Created

**Response:** Empty body

---

### 4. POST /Category/varios

**Description:** Create multiple categories at once

**Method:** POST  
**Authentication:** Required (JWT Token with admin claims)  
**Request Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body:**
```json
[
  {
    "name": "Machine Learning"
  },
  {
    "name": "Cloud Computing"
  },
  {
    "name": "DevOps"
  }
]
```

**Response Status:** 201 Created

**Response:** Empty body

---

### 5. PUT /Category/{id}

**Description:** Update an existing category

**Method:** PUT  
**Authentication:** Required (JWT Token with admin claims)  
**Path Parameters:**
- `id` (Long): Category ID to update

**Request Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "Advanced Programming"
}
```

**Response Status:** 200 OK or 404 Not Found

**Response:** Empty body

---

### 6. DELETE /Category/{id}

**Description:** Delete a category

**Method:** DELETE  
**Authentication:** Required (JWT Token with admin claims)  
**Path Parameters:**
- `id` (Long): Category ID to delete

**Request Headers:**
```
Authorization: Bearer <JWT_TOKEN>
```

**Response Status:** 204 No Content

**Response:** Empty body

---

## Serie Endpoints

Base URL: `/Serie`

### 1. GET /Serie

**Description:** Get all series

**Method:** GET  
**Authentication:** None  
**Response Status:** 200 OK

**Response:**
```json
[
  {
    "id": 1,
    "name": "Java Masterclass",
    "classification": 12
  },
  {
    "id": 2,
    "name": "Python Fundamentals",
    "classification": 7
  },
  {
    "id": 3,
    "name": "Web Development Pro",
    "classification": 16
  }
]
```

---

### 2. GET /Serie/{id}

**Description:** Get a specific serie by ID

**Method:** GET  
**Authentication:** None  
**Path Parameters:**
- `id` (Long): Serie ID

**Response Status:** 200 OK

**Example Request:**
```
GET /Serie/1
```

**Response:**
```json
{
  "id": 1,
  "name": "Java Masterclass",
  "classification": 12
}
```

---

### 3. POST /Serie

**Description:** Create a new serie

**Method:** POST  
**Authentication:** Required (JWT Token with admin claims)  
**Request Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "React Advanced",
  "classification": 14
}
```

**Response Status:** 201 Created

**Response:** Empty body

---

### 4. POST /Serie/varios

**Description:** Create multiple series at once

**Method:** POST  
**Authentication:** Required (JWT Token with admin claims)  
**Request Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body:**
```json
[
  {
    "name": "Angular Pro",
    "classification": 16
  },
  {
    "name": "Vue Essentials",
    "classification": 10
  },
  {
    "name": "Svelte Basics",
    "classification": 8
  }
]
```

**Response Status:** 201 Created

**Response:** Empty body

---

### 5. PUT /Serie/{id}

**Description:** Update an existing serie

**Method:** PUT  
**Authentication:** Required (JWT Token with admin claims)  
**Path Parameters:**
- `id` (Long): Serie ID to update

**Request Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "React Complete Course",
  "classification": 16
}
```

**Response Status:** 200 OK or 404 Not Found

**Response:** Empty body

---

### 6. DELETE /Serie/{id}

**Description:** Delete a serie

**Method:** DELETE  
**Authentication:** Required (JWT Token with admin claims)  
**Path Parameters:**
- `id` (Long): Serie ID to delete

**Request Headers:**
```
Authorization: Bearer <JWT_TOKEN>
```

**Response Status:** 204 No Content

**Response:** Empty body

---

## Estudi (Study) Endpoints

Base URL: `/Estudi`

### 1. GET /Estudi

**Description:** Get all studies

**Method:** GET  
**Authentication:** None  
**Response Status:** 200 OK

**Response:**
```json
[
  {
    "id": 1,
    "name": "Computer Science"
  },
  {
    "id": 2,
    "name": "Software Engineering"
  },
  {
    "id": 3,
    "name": "Information Technology"
  }
]
```

---

### 2. GET /Estudi/{id}

**Description:** Get a specific study by ID

**Method:** GET  
**Authentication:** None  
**Path Parameters:**
- `id` (Long): Study ID

**Response Status:** 200 OK

**Example Request:**
```
GET /Estudi/1
```

**Response:**
```json
{
  "id": 1,
  "name": "Computer Science"
}
```

---

### 3. POST /Estudi

**Description:** Create a new study

**Method:** POST  
**Authentication:** Required (JWT Token with admin claims)  
**Request Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "Data Science"
}
```

**Response Status:** 201 Created

**Response:** Empty body

---

### 4. POST /Estudi/varios

**Description:** Create multiple studies at once

**Method:** POST  
**Authentication:** Required (JWT Token with admin claims)  
**Request Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body:**
```json
[
  {
    "name": "Cybersecurity"
  },
  {
    "name": "Cloud Architecture"
  },
  {
    "name": "Machine Learning"
  }
]
```

**Response Status:** 201 Created

**Response:** Empty body

---

### 5. PUT /Estudi/{id}

**Description:** Update an existing study

**Method:** PUT  
**Authentication:** Required (JWT Token with admin claims)  
**Path Parameters:**
- `id` (Long): Study ID to update

**Request Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "Advanced Computer Science"
}
```

**Response Status:** 200 OK or 404 Not Found

**Response:** Empty body

---

### 6. DELETE /Estudi/{id}

**Description:** Delete a study

**Method:** DELETE  
**Authentication:** Required (JWT Token with admin claims)  
**Path Parameters:**
- `id` (Long): Study ID to delete

**Request Headers:**
```
Authorization: Bearer <JWT_TOKEN>
```

**Response Status:** 204 No Content

**Response:** Empty body

---

## Summary

### Authentication

- **Unauthenticated endpoints:** All GET endpoints (list and by ID)
- **Authenticated endpoints:** POST, PUT, DELETE require JWT token with `is_admin: true` claim

### HTTP Status Codes

- `200 OK` - Successful GET/PUT request
- `201 Created` - Successful POST request
- `204 No Content` - Successful DELETE request
- `404 Not Found` - Resource not found (GET/PUT/DELETE on non-existent ID)
- `401 Unauthorized` - Missing or invalid authentication
- `403 Forbidden` - Authenticated but lacking admin privileges

### CORS Configuration

All endpoints (except specific ones in VideoCatalegController) have CORS enabled for origin `*`

### Error Handling

- If a resource is not found during UPDATE or DELETE, the endpoint returns 404 Not Found
- Invalid JWT tokens will return 401 Unauthorized
- Non-admin users attempting to modify resources will return 403 Forbidden
