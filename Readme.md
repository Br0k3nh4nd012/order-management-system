# Order Management System

# Setup/Cofigurations
## Prerequisites
- Docker ([Install Docker](https://docs.docker.com/get-docker/))
- Docker Compose ([Install Docker Compose](https://docs.docker.com/compose/install/))

## Installation & Setup

1. Clone the repository and move into the project dir:
   ```bash
   git clone https://github.com/yourusername/order-management-system.git
   cd order-management-system
   ```
2. Start the server using Docker Compose:
   ```bash
   docker-compose up
   ```
3. Ensure all the services (Rails server, postgres, redis, Sidekiq, mail) are up and running successfully.
4. Server is running at http://localhost:3010.
5. Email server is running at http://localhost:3003.
6. Admin portal will be available at http://localhost:3010/admin for performing CRUD operations on Customer, Item, InventoryItem.


## System Architecture & Worflow


For detailed information on the system architecture, workflow design, and scalability considerations, refer to the following document:

[System Design Documentation](https://docs.google.com/document/d/1CibRXw7OF1bSCw3Va22JBmaxJUmOQd4nc7kcw-t6R7U)



## API Documentation

### Base URL
```
http://localhost:3010
```

## Endpoints

### 1. Create Order
Creates a new order with specified items.

**Endpoint:** `POST /api/v1/orders`

**Request Body:**
```json
{
    "customer_id": 1,
    "items": [
      {
        "item_id": 1,
        "quantity": 2
      },
      {
        "item_id": 2,
        "quantity": 1
      }
    ]
}
```

**Response:**
- Success (201 Created):
```json
{
  "id": 1,
  "customer_id": 1,
  "status": "pending",
  "total_price": 150.00,
  "items": [
    {
      "item_id": 1,
      "quantity": 2,
      "price": 100.00
    },
    {
      "item_id": 2,
      "quantity": 1,
      "price": 50.00
    }
  ]
}
```

- Error (422 Unprocessable Entity):
```json
{
  "error": "Error message describing the issue"
}
```

### 2. List Orders
Retrieves all orders.

**Endpoint:** `GET /api/v1/orders`

**Response:**
- Success (200 OK):
```json
[
  {
    "id": 1,
    "customer_id": 1,
    "status": "pending",
    "items": [
      {
        "item_id": 1,
        "quantity": 2,
        "price": 100.00
      }
    ]
  }
]
```

### 3. Get Order Details
Retrieves details of a specific order.

**Endpoint:** `GET /api/v1/orders/:id`

**Response:**
- Success (200 OK):
```json
{
  "id": 1,
  "customer_id": 1,
  "status": "pending",
  "total_price": 150.00,
  "items": [
    {
      "item_id": 1,
      "quantity": 2,
      "price": 100.00
    }
  ]
}
```

- Error (404 Not Found):
```json
{
  "error": "Order not found"
}
```

### 4. Update Order Status
Updates the status of an order.
Accepted status values:
- 0: cancelled
- 1: placed
- 2: preparing
- 3: out_for_delivery
- 4: delivered

**Endpoint:** `PATCH /api/v1/orders/:id` 

**Request Body:**
```json
{
  "order": {
    "status": 4
  }
}
```

**Response:**
- Success (200 OK):
```json
{
  "id": 1,
  "customer_id": 1,
  "status": "delivered",
  "total_price": 150.00,
  "items": [
    {
      "item_id": 1,
      "quantity": 2,
      "price": 100.00
    }
  ]
}
```

- Error (422 Unprocessable Entity):
[When cancelled order is updated]
```json
{
  "error": "Order is in cancelled status. Cannot update."
}
```

## Status Codes

| Status Code | Description |
|-------------|-------------|
| 200 | Success |
| 201 | Created |
| 404 | Not Found |
| 422 | Unprocessable Entity |

## Error Response Format
All error responses follow this format:
```json
{
  "error": "Error message describing the issue"
}
```

## Notes
1. The system uses optimistic locking to handle concurrent modifications
2. Order status can be one of: "cancelled", "placed", "preparing", "out_for_delivery", "delivered"
3. Once an order is cancelled, its status cannot be changed
4. All monetary values are in the system's base currency(INR)
5. Item quantities must be positive integers
6. The system automatically calculates the total price based on item prices and quantities


## Versioning
- Current API version: v1
- Version is included in the URL path
- Future versions will maintain backward compatibility where possible
