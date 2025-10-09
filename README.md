🔗 Blockchain-powered supply chain transparency for ethical mineral sourcing

## 🌍 Problem

Rare earth mineral extraction (cobalt, lithium) is plagued by:
- 👶 Child labor exploitation
- 🏴‍☠️ Illegal mining operations  
- 🤐 Opaque supply chains
- ❌ Lack of ESG compliance tracking

## 💡 Solution

A decentralized system providing complete traceability from mine-to-market through:
- ✅ Verified mine-of-origin tags
- 📡 IoT-enabled shipment tracking
- 🏆 ESG compliance scoring
- 🔍 Transparent ownership history

## 🚀 Features

### 🏭 Mine Management
- Register mining operations with location & mineral type
- Third-party verification system
- ESG scoring (0-100 scale)
- Only verified mines can create mineral batches

### 💎 Mineral Batch Tracking  
- Create traceable batches from verified mines
- Automatic ESG compliance tagging (≥70 score)
- Complete ownership transfer history
- Status tracking throughout supply chain

### 🚚 Shipment Monitoring
- IoT device integration for real-time tracking
- Temperature & humidity monitoring
- Location-based status updates
- Carrier verification system

### 📊 Transparency Features
- Full batch origin verification
- Historical ownership tracking
- Real-time shipment status
- ESG compliance verification

## 🛠️ Usage

### Deploy Contract
```bash
clarinet console
```

### Register a Mine
```clarity
(contract-call? .Global-Rare-Earth-Mineral-Transparency register-mine 
    "Cobalt Mine Alpha" 
    "Democratic Republic of Congo" 
    "cobalt")
```

### Verify Mine (Authorized Only)
```clarity
(contract-call? .Global-Rare-Earth-Mineral-Transparency verify-mine u1 u85)
```

### Create Mineral Batch
```clarity
(contract-call? .Global-Rare-Earth-Mineral-Transparency create-mineral-batch 
    u1 
    u1000 
    "cobalt")
```

### Transfer Ownership
```clarity
(contract-call? .Global-Rare-Earth-Mineral-Transparency transfer-batch 
    u1 
    'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG 
    "Processing Facility A")
```

### Create Shipment
```clarity
(contract-call? .Global-Rare-Earth-Mineral-Transparency create-shipment 
    u1 
    "DRC Mine Site" 
    "Shanghai Port" 
    "IOT-SENSOR-001")
```

### Update IoT Data
```clarity
(contract-call? .Global-Rare-Earth-Mineral-Transparency update-shipment-iot 
    u1 
    25 
    60)
```

### Complete Delivery
```clarity
(contract-call? .Global-Rare-Earth-Mineral-Transparency complete-shipment u1)
```

## 🔍 Query Functions

### Get Mine Details
```clarity
(contract-call? .Global-Rare-Earth-Mineral-Transparency get-mine u1)
```

### Get Batch Information  
```clarity
(contract-call? .Global-Rare-Earth-Mineral-Transparency get-mineral-batch u1)
```

### Get Batch Origin
```clarity
(contract-call? .Global-Rare-Earth-Mineral-Transparency get-batch-origin u1)
```

### Track Shipment
```clarity
(contract-call? .Global-Rare-Earth-Mineral-Transparency get-shipment u1)
```

### View History
```clarity
(contract-call? .Global-Rare-Earth-Mineral-Transparency get-batch-history-entry u1 u0)
```

## 🔐 Access Control

### Contract Owner
- Add/remove authorized verifiers
- Full system administration

### Authorized Verifiers  
- Verify mine operations
- Assign ESG scores

### Mine Owners
- Register mines
- Create mineral batches
- Transfer ownership

### Carriers
- Create shipments
- Update IoT sensor data
- Complete deliveries

## 📱 IoT Integration

The system supports real-time sensor data including:
- 🌡️ Temperature monitoring
- 💧 Humidity tracking  
- 📍 GPS location updates
- ⏰ Timestamp verification

## 🏆 ESG Scoring

Mines receive scores from 0-100 based on:
- Environmental impact
- Social responsibility  
- Governance standards
- Labor practices

**ESG Compliant**: Scores ≥70 automatically tagged as compliant

## 🛡️ Security Features

- Multi-level authorization system
- Immutable tracking records
- Verified mine registration only
- Secure ownership transfers

## 🔄 Supply Chain Flow

```
Mine Registration → ESG Verification → Mineral Extraction → 
Batch Creation → Ownership Transfer → Shipment Tracking → 
IoT Monitoring → Delivery Confirmation
```

## 🎯 MVP Scope

This initial version provides core traceability features. Future enhancements may include:
- Multi-token support
- Advanced analytics dashboard
- Integration with existing ERP systems
- Mobile app for field operations

## 🚨 Batch Pause/Unpause

### Emergency Compliance Control
- **Pause Batches:** Authorized verifiers or contract owner can freeze batches for regulatory issues
- **Unpause Batches:** Restore normal operations once issues are resolved
- **Status Queries:** Check if a batch is currently paused

### Usage Examples

#### Pause a Batch (Authorized Only)
```clarity
(contract-call? .Global-Rare-Earth-Mineral-Transparency pause-batch u1)
```

#### Unpause a Batch (Authorized Only)
```clarity
(contract-call? .Global-Rare-Earth-Mineral-Transparency unpause-batch u1)
```

#### Check Pause Status
```clarity
(contract-call? .Global-Rare-Earth-Mineral-Transparency is-batch-paused u1)
```

### Security Features
- Multi-level authorization (owner + verifiers only)
- Prevents transfers and shipments when paused
- Immutable pause records on-chain
- Rapid emergency response capability

### Integration with Supply Chain
When a batch is paused:
- ❌ Transfer operations blocked
- ❌ Shipment creation blocked
- ✅ All other operations continue normally
- 🔄 Unpause restores full functionality

This feature enhances regulatory compliance and provides stakeholders with confidence in the system's ability to handle emergencies swiftly and transparently.
