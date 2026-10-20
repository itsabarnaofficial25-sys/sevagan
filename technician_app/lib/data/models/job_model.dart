enum JobStatus { pending, accepted, started, completed, cancelled }

class Job {
  final String id;
  final String customerName;
  final String serviceType;
  final String serviceTypeTa;  
  final String description;
  final String descriptionTa;  
  final String address;
  final double latitude;
  final double longitude;
  final double price;
  final DateTime createdAt;
  JobStatus status;
  final DateTime? preferredDateTime;
  final DateTime? proposedDateTime;
  final String? schedulingStatus;
  final String? schedulingNote;

  Job({
    required this.id,
    required this.customerName,
    required this.serviceType,
    this.serviceTypeTa = '',  
    required this.description,
    this.descriptionTa = '',  
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.price,
    required this.createdAt,
    this.status = JobStatus.pending,
    this.preferredDateTime,
    this.proposedDateTime,
    this.schedulingStatus,
    this.schedulingNote,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'].toString(),
      customerName: json['customerName'] ?? json['customer']?['name'] ?? 'Unknown',
      serviceType: json['serviceType'] ?? json['serviceCategory']?['nameEn'] ?? 'Service',
      serviceTypeTa: json['serviceTypeTa'] ?? json['serviceCategory']?['nameTa'] ?? '',  // ← ADD THIS
      description: json['description'] ?? '',
      descriptionTa: json['descriptionTa'] ?? '',  // ← ADD THIS
      address: json['address'] ?? json['locationAddress'] ?? 'Address not available',
      latitude: (json['latitude'] ?? json['locationLat'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? json['locationLng'] ?? 0.0).toDouble(),
      price: (json['price'] ?? json['estimatedPrice'] ?? 0.0).toDouble(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      status: _getStatusFromString(json['status']),
      preferredDateTime: json['preferredDateTime'] != null 
          ? DateTime.parse(json['preferredDateTime']) 
          : null,
      proposedDateTime: json['proposedDateTime'] != null 
          ? DateTime.parse(json['proposedDateTime']) 
          : null,
      schedulingStatus: json['schedulingStatus'],
      schedulingNote: json['schedulingNote'],
    );
  }

  // Helper method to get service type based on language
  String getServiceType(String languageCode) {
    if (languageCode == 'ta' && serviceTypeTa.isNotEmpty) {
      return serviceTypeTa;
    }
    return serviceType;
  }

  // Helper method to get description based on language
  String getDescription(String languageCode) {
    if (languageCode == 'ta' && descriptionTa.isNotEmpty) {
      return descriptionTa;
    }
    return description;
  }

  static JobStatus _getStatusFromString(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
      case 'REQUESTED':
        return JobStatus.pending;
      case 'ACCEPTED':
      case 'TECHNICIAN_ASSIGNED':
        return JobStatus.accepted;
      case 'STARTED':
      case 'JOB_STARTED':
        return JobStatus.started;
      case 'COMPLETED':
      case 'JOB_COMPLETED':
        return JobStatus.completed;
      case 'CANCELLED':
        return JobStatus.cancelled;
      default:
        return JobStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'serviceType': serviceType,
      'serviceTypeTa': serviceTypeTa,  // ← ADD THIS
      'description': description,
      'descriptionTa': descriptionTa,  // ← ADD THIS
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'preferredDateTime': preferredDateTime?.toIso8601String(),
      'proposedDateTime': proposedDateTime?.toIso8601String(),
      'schedulingStatus': schedulingStatus,
      'schedulingNote': schedulingNote,
    };
  }
}