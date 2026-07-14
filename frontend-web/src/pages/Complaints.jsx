import { useEffect, useMemo, useState } from 'react';
import { AlertCircle, Clock, MapPin, Tag, X } from 'lucide-react';
import { getComplaints } from '../services/complaintsService';

const Complaints = () => {
  const [complaints, setComplaints] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [currentTab, setCurrentTab] = useState('All');
  const [selectedComplaint, setSelectedComplaint] = useState(null);
  const [showRecentOnly, setShowRecentOnly] = useState(false);

  useEffect(() => {
    const load = async () => {
      setLoading(true);
      const data = await getComplaints();
      setComplaints(data);
      setLoading(false);
    };
    load();
  }, []);

  const filteredComplaints = useMemo(() => {
    let list = complaints.filter((item) => {
      const matchesSearch = `${item.location} ${item.type}`.toLowerCase().includes(search.toLowerCase());
      const matchesTab = currentTab === 'All' || item.status === currentTab;
      return matchesSearch && matchesTab;
    });

    // "New Complaint" toggle — show only the 3 most recently reported
    // complaints. Mock data is already ordered most-recent-first (id
    // #145 is newer than #144, etc.), so slicing the first 3 works here.
    // Once connected to the real backend, this should sort by the
    // actual created_at/time field before slicing.
    if (showRecentOnly) {
      list = list.slice(0, 3);
    }

    return list;
  }, [complaints, search, currentTab, showRecentOnly]);

  const getPriorityClass = (priority) => {
    if (priority === 'High') return 'priority-high';
    if (priority === 'Medium') return 'priority-medium';
    return 'priority-low';
  };

  const getStatusClass = (status) => {
    if (status === 'Pending') return 'status-pending';
    if (status === 'In Progress') return 'status-inprogress';
    return 'status-resolved';
  };

  return (
    <div className="content-wrapper">
      <div className="content-header">
        <div>
          <h2 className="header-title">Complaints</h2>
          <p className="header-subtitle">Track and review reported waste issues.</p>
        </div>
        <button
          className="primary-btn"
          onClick={() => setShowRecentOnly((prev) => !prev)}
        >
          {showRecentOnly ? 'Show All Complaints' : 'New Complaint'}
        </button>
      </div>

      {showRecentOnly && (
        <div className="empty-state" style={{ padding: '10px 16px', textAlign: 'left', background: '#eff6ff', color: '#1d4ed8', borderRadius: '10px', fontSize: '13px', fontWeight: 500 }}>
          Showing the 3 most recently reported complaints.
        </div>
      )}

      <div className="panel-card">
        <div className="content-header">
          <input className="search-input" placeholder="Search by location or type" value={search} onChange={(e) => setSearch(e.target.value)} />
          <div className="tab-group">
            {['All', 'Pending', 'In Progress', 'Resolved'].map((tab) => (
              <button key={tab} className={`tab-btn ${currentTab === tab ? 'active' : ''}`} onClick={() => setCurrentTab(tab)}>{tab}</button>
            ))}
          </div>
        </div>
        {loading ? <div className="empty-state">Loading complaints...</div> : (
          <table className="data-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Location</th>
                <th>Type</th>
                <th>Priority</th>
                <th>Status</th>
                <th>Reported At</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredComplaints.map((item) => (
                <tr key={item.id}>
                  <td>{item.id}</td>
                  <td>{item.location}</td>
                  <td>{item.type} 🗑</td>
                  <td><span className={`status-badge ${getPriorityClass(item.priority)}`}>{item.priority}</span></td>
                  <td><span className={`status-badge ${getStatusClass(item.status)}`}>{item.status}</span></td>
                  <td>{item.time}</td>
                  <td><button className="secondary-btn" onClick={() => setSelectedComplaint(item)}>View</button></td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {selectedComplaint && (
        <div className="modal-backdrop" onClick={() => setSelectedComplaint(null)}>
          <div className="modal-card" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3>Complaint Details</h3>
              <button className="icon-btn" onClick={() => setSelectedComplaint(null)}><X size={18} /></button>
            </div>
            <div className="modal-body">
              <div className="detail-row"><span className="detail-label">ID</span><span>{selectedComplaint.id}</span></div>
              <div className="detail-row"><span className="detail-label">Status</span><span className={`status-badge ${getStatusClass(selectedComplaint.status)}`}>{selectedComplaint.status}</span></div>
              <div className="detail-row"><MapPin size={16} /><span>{selectedComplaint.location}</span></div>
              <div className="detail-row"><Tag size={16} /><span>{selectedComplaint.type}</span></div>
              <div className="detail-row"><AlertCircle size={16} /><span>{selectedComplaint.priority}</span></div>
              <div className="detail-row"><Clock size={16} /><span>{selectedComplaint.time}</span></div>
            </div>
            <div className="modal-footer">
              <button className="secondary-btn" onClick={() => setSelectedComplaint(null)}>Close</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Complaints;
