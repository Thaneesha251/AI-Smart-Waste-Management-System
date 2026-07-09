import '../models/complaint.dart';

class ComplaintService {
  Future<List<Complaint>> getComplaints() async {
    // Mock Data for Citizen
    await Future.delayed(const Duration(seconds: 1));
    return [
      Complaint(
        id: '1024',
        title: 'Overflowing Dustbin',
        description: 'Trash is scattered outside the bin near the park entrance.',
        location: 'Chennai',
        area: 'Anna Nagar, Sector 7',
        zone: 'Zone 5',
        status: ComplaintStatus.assigned,
        priority: 'High',
        wasteType: 'General',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        assignedAuthority: 'City Municipality',
        expectedResolution: DateTime.now().add(const Duration(days: 1)),
      ),
      Complaint(
        id: '1025',
        title: 'Plastic Waste Pile',
        description: 'Large amount of plastic bottles dumped near the drainage.',
        location: 'Chennai',
        area: 'Anna Nagar West',
        zone: 'Zone 5',
        status: ComplaintStatus.pending,
        priority: 'Medium',
        wasteType: 'Plastic',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        assignedAuthority: 'City Municipality',
        expectedResolution: DateTime.now().add(const Duration(days: 2)),
      ),
    ];
  }

  Future<List<Complaint>> getWorkerTasks() async {
    // Mock Data for Worker
    await Future.delayed(const Duration(seconds: 1));
    return [
      Complaint(
        id: '1024',
        title: 'Overflowing Dustbin',
        description: 'Trash is scattered outside the bin near the park entrance.',
        location: 'Chennai',
        area: 'Anna Nagar, Sector 7',
        zone: 'Zone 5',
        status: ComplaintStatus.assigned,
        priority: 'High',
        wasteType: 'General',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        assignedAuthority: 'City Municipality',
        expectedResolution: DateTime.now().add(const Duration(days: 1)),
        imageUrl: 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?auto=format&fit=crop&q=80&w=400',
      ),
    ];
  }
}
