# Commission Field Enhancement - Testing Guide

## Overview
The commission field enhancement allows service categories to use either **percentage-based** or **fixed-amount** commissions.

## Changes Made

### Backend
1. **ServiceCategory Entity** (`backend/src/services/entities/service-category.entity.ts`)
   - Added `commissionType` field (PERCENTAGE | FIXED_AMOUNT)
   - Added `commissionAmount` field (nullable float)

2. **Database Migration** (`backend/src/database/migrations/1704537600000-AddCommissionTypeFields.ts`)
   - Adds `commission_type` column with default 'PERCENTAGE'
   - Adds `commission_amount` column (nullable)
   - Ensures backward compatibility

3. **Payment Service** (`backend/src/payments/payments.service.ts`)
   - Added `calculateCommission()` method
   - Supports both percentage and fixed amount calculation

### Frontend (Admin Panel)
4. **Services Page** (`admin-panel/src/pages/Services.jsx`)
   - Added commission type radio buttons
   - Conditional form fields based on selected type
   - Updated table to display commission type
   - Full modal form for create/edit

## Testing Instructions

### Prerequisites
```bash
# Run database migration
cd backend
npm run migration:run
```

### Test Case 1: Create Service with Percentage Commission

**Steps:**
1. Open admin panel: http://localhost:3001
2. Navigate to Services page
3. Click "Add Service" button
4. Fill in the form:
   - Name (English): "Electrician"
   - Name (Tamil): "மின்சாரம்"
   - Base Price: 200
   - Min Price: 150
   - Max Price: 500
   - Commission Type: Select "Percentage (%)"
   - Commission Percentage: 15

5. Click "Create"

**Expected Result:**
- Service created successfully
- Table shows: "15% (Percentage)" in Commission column

### Test Case 2: Create Service with Fixed Amount Commission

**Steps:**
1. Click "Add Service" button
2. Fill in the form:
   - Name (English): "Plumber"
   - Name (Tamil): "குழாய் பழுது"
   - Base Price: 250
   - Min Price: 200
   - Max Price: 600
   - Commission Type: Select "Fixed Amount (₹)"
   - Commission Amount: 50

3. Click "Create"

**Expected Result:**
- Service created successfully
- Table shows: "₹50 (Fixed)" in Commission column

### Test Case 3: Edit Existing Service

**Steps:**
1. Click "Edit" on an existing service
2. Change commission type from Percentage to Fixed Amount (or vice versa)
3. Enter appropriate value
4. Click "Update"

**Expected Result:**
- Service updated successfully
- Commission type and value reflected in table

### Test Case 4: Payment Calculation - Percentage

**Steps:**
1. Create a service request for "Electrician" (15% commission)
2. Complete the job with final price: ₹400
3. Check payment breakdown

**Expected Result:**
- Final Price: ₹400
- Commission (15%): ₹60
- Technician Amount: ₹340

### Test Case 5: Payment Calculation - Fixed Amount

**Steps:**
1. Create a service request for "Plumber" (₹50 fixed commission)
2. Complete the job with final price: ₹500
3. Check payment breakdown

**Expected Result:**
- Final Price: ₹500
- Commission (Fixed): ₹50
- Technician Amount: ₹450

### Test Case 6: Backward Compatibility

**Steps:**
1. Check existing services created before migration
2. Verify they still work correctly

**Expected Result:**
- Existing services default to PERCENTAGE type
- Commission calculations work as before

## API Testing (Optional)

### Create Service with Percentage
```bash
POST http://localhost:3000/admin/services
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "nameEn": "AC Service",
  "nameTa": "ஏசி சேவை",
  "basePrice": 300,
  "minPrice": 250,
  "maxPrice": 800,
  "commissionType": "PERCENTAGE",
  "commissionPercent": 20
}
```

### Create Service with Fixed Amount
```bash
POST http://localhost:3000/admin/services
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "nameEn": "Motor Repair",
  "nameTa": "மோட்டார் பழுது",
  "basePrice": 350,
  "minPrice": 300,
  "maxPrice": 900,
  "commissionType": "FIXED_AMOUNT",
  "commissionAmount": 75
}
```

## Validation Rules

1. **Percentage Type:**
   - `commissionPercent` is required
   - Must be a number between 0 and 100

2. **Fixed Amount Type:**
   - `commissionAmount` is required
   - Must be a positive number

3. **Both Types:**
   - `commissionType` defaults to 'PERCENTAGE'
   - Backward compatible with existing data

## Files Modified

- `backend/src/services/entities/service-category.entity.ts`
- `backend/src/database/migrations/1704537600000-AddCommissionTypeFields.ts`
- `backend/src/payments/payments.service.ts`
- `admin-panel/src/pages/Services.jsx`

## Known Issues
None

## Next Steps
- [ ] Test with real service requests
- [ ] Verify payment calculations in production
- [ ] Monitor for any edge cases
