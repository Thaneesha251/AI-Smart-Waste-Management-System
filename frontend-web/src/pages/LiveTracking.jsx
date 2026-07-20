import { useEffect, useMemo, useState } from 'react';
import { CheckCircle2, CircleAlert, MapPin, Search, ShieldAlert, X } from 'lucide-react';
import { getComplaints } from '../services/complaintsService';
import { getWorkersForMap, assignWorkerToComplaint, unassignWorker } from '../services/workersService';
import Map from '../components/Map';
import '../styles/LiveTracking.css';

const LiveTracking = () => {
  const [activeTab, setActiveTab] = useState('Complaints');
  const [search, setSearch] = useState('');
  const [complaints, setComplaints] = useState([]);
  const [workers, setWorkers] = useState([]);
  const [selectedComplaint, setSelectedComplaint] = useState(null);
  const [selectedWorker, setSelectedWorker] = useState(null);
  const [showModal, setShowModal] = useState(false);
  const [success, setSuccess] = useState(false);

  useEffect(() => {
    const loadInitial = async () => {
      const complaintData = await getComplaints();
      const workerData = await getWorkersForMap();
      setComplaints(complaintData);
      setWorkers(workerData);
    };
    loadInitial();

    const interval = setInterval(async () => {
      const workerData = await getWorkersForMap();
      setWorkers(workerData);
    }, 5000);

    return () => clearInterval(interval);
  }, []);

  const idleWorkers = useMemo(() => workers.filter((worker) => worker.currentTask === 'None'), [workers]);

  const filteredComplaints = useMemo(() => {
    const term = search.replace('#', '').toLowerCase().trim();
    if (!term) return complaints;
    return complaints.filter((item) =>
      String(item.id).toLowerCase().replace('#', '').includes(term) ||
      (item.location || '').toLowerCase().includes(term) ||
      (item.type || '').toLowerCase().includes(term)
    );
  }, [complaints, search]);

  const filteredWorkers = useMemo(() => {
    const term = search.toLowerCase().trim();
    if (!term) return workers;
    return workers.filter((worker) => (worker.name || '').toLowerCase().includes(term));
  }, [workers, search]);

  const handleAssign = async () => {
    if (!selectedComplaint || !selectedWorker) return;
    await assignWorkerToComplaint(selectedWorker.id, selectedComplaint.id);
    setSuccess(true);
    setTimeout(async () => {
      setShowModal(false);
      setSelectedWorker(null);
      setSuccess(false);
      setComplaints((prev) => prev.map((item) => item.id === selectedComplaint.id ? { ...item, assignedWorker: selectedWorker.name } : item));
      const updatedWorkers = await getWorkersForMap();
      setWorkers(updatedWorkers);
    }, 1400);
  };

  const handleOpenAssignModal = async (item) => {
    if (item.assignedWorker) {
      const previousWorker = workers.find(w => w.name === item.assignedWorker);
      if (previousWorker) {
        await unassignWorker(previousWorker.id, item.id);
        const updatedWorkers = await getWorkersForMap();
        setWorkers(updatedWorkers);
      }
    }
    setSelectedComplaint(item);
    setShowModal(true);
  };

  const markers = useMemo(() => {
    const items = [];
    complaints.forEach((complaint) => {
      items.push({ id: complaint.id, lat: 11.0168 + (Math.random() - 0.5) / 100, lng: 76.9558 + (Math.random() - 0.5) / 100, icon: complaint.assignedWorker ? '🟡' : '🔴', popup: `${complaint.id} - ${complaint.type}` });
    });
    workers.forEach((worker) => {
      items.push({ id: `worker-${worker.id}`, lat: worker.lat, lng: worker.lng, icon: worker.currentTask === 'None' ? '🟢' : '🟡', popup: `${worker.name} - ${worker.currentTask}` });
    });
    items.push({ id: 'hazard-1', lat: 11.0185, lng: 76.9595, icon: '⚠', popup: 'Hazard Zone' });
    return items;
  }, [complaints, workers]);

  return (
    <div className="live-tracking-container">
      <aside className="lt-sidebar">
        <div className="lt-toolbar">
          <div className="search-box dark-search">
            <Search size={16} />
            <input
              type="text"
              placeholder="Search by complaint #, location, or waste type..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
        </div>
        <div className="lt-tabs">
          <button className={`lt-tab ${activeTab === 'Complaints' ? 'active' : ''}`} onClick={() => setActiveTab('Complaints')}>Complaints</button>
          <button className={`lt-tab ${activeTab === 'Workers' ? 'active' : ''}`} onClick={() => setActiveTab('Workers')}>Workers</button>
        </div>

        {activeTab === 'Complaints' ? (
          <div className="lt-list">
            {filteredComplaints.length === 0 && (
              <div className="empty-state">No complaints match "{search}"</div>
            )}
            {filteredComplaints.map((item) => (
              <div key={item.id} className="lt-card">
                <div className="lt-card-head">
                  <h4>{item.id}</h4>
                  <span className={`lt-priority ${item.priority === 'High' ? 'high' : item.priority === 'Medium' ? 'medium' : 'low'}`}>{(item.priority || '').toUpperCase()}</span>
                </div>
                <div className="lt-muted">{item.type}</div>
                <div className="lt-muted"><MapPin size={14} /> {item.location}</div>
                <div className="lt-muted">Status: {item.status}</div>
                <div className="lt-muted">Assigned worker: <span className={item.assignedWorker ? 'assigned-worker' : ''}>{item.assignedWorker || 'Unassigned'}</span></div>
                <button className="lt-btn" onClick={() => handleOpenAssignModal(item)}> {item.assignedWorker ? 'Reassign Worker' : 'Assign Worker'}</button>
              </div>
            ))}
          </div>
        ) : (
          <div className="lt-list">
            {filteredWorkers.length === 0 && (
              <div className="empty-state">No workers match "{search}"</div>
            )}
            {filteredWorkers.map((worker) => (
              <div key={worker.id} className="lt-card">
                <div className="lt-card-head">
                  <h4>{worker.name}</h4>
                  <span className={`lt-badge ${worker.status === 'On Duty' ? 'online' : 'offline'}`}>{worker.status === 'On Duty' ? 'Online' : 'Offline'}</span>
                </div>
                <div className="lt-muted">Current Task: {worker.currentTask}</div>
                <div className="lt-muted">Battery: {worker.battery}%</div>
                <div className="lt-muted">SOS: {worker.sos ? 'YES' : 'NO'}</div>
                {worker.progress > 0 && <div className="progress-row"><div className="progress-bar"><span style={{ width: `${worker.progress}%` }} /></div> <span>{worker.progress}%</span></div>}
              </div>
            ))}
          </div>
        )}
      </aside>

      <div className="lt-map-area">
        <Map markers={markers} />
        <div className="map-legend">
          <div><span>🔴</span> Unassigned complaint</div>
          <div><span>🟡</span> Assigned / busy</div>
          <div><span>🟢</span> Idle workers</div>
          <div><span>⚠</span> Hazard zones</div>
        </div>
      </div>

      {showModal && (
        <div className="modal-backdrop" onClick={() => setShowModal(false)}>
          <div className="assign-modal" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3>Assign Worker</h3>
              <button className="icon-btn" onClick={() => setShowModal(false)}><X size={18} /></button>
            </div>
            <div className="modal-body">
              <label className="field-label">Complaint ID</label>
              <input className="assign-input" value={selectedComplaint?.id || ''} onChange={(e) => setSelectedComplaint((prev) => ({ ...prev, id: e.target.value }))} />
              <div className="hint-text">Location: {selectedComplaint?.location} • Waste Type: {selectedComplaint?.type} • Priority: {selectedComplaint?.priority}</div>
              <label className="field-label">Worker Search</label>
              <input className="assign-input" placeholder="Search worker" />
              <div className="worker-list">
                {idleWorkers.length === 0 ? <div className="empty-state">No idle workers available.</div> : idleWorkers.map((worker) => (
                  <button key={worker.id} className={`worker-pick-item ${selectedWorker?.id === worker.id ? 'selected' : ''}`} onClick={() => setSelectedWorker(worker)}>
                    <div className="worker-pick-avatar">{worker.name.slice(0, 2).toUpperCase()}</div>
                    <div>
                      <div>{worker.name}</div>
                      <div className="worker-pick-meta">{worker.battery}% • 🟢 Idle</div>
                    </div>
                    {selectedWorker?.id === worker.id ? <CheckCircle2 size={18} /> : null}
                  </button>
                ))}
              </div>
              {selectedWorker && <div className="assign-summary">Assigning {selectedComplaint?.id} → {selectedWorker.name}</div>}
              {success && <div className="assign-success"><ShieldAlert size={16} /> Assigned successfully.</div>}
            </div>
            <div className="modal-footer">
              <button className="assign-confirm-btn" disabled={!selectedWorker || success} onClick={handleAssign}>{selectedWorker ? `Assign ${selectedWorker.name}` : 'Assign Worker'}</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default LiveTracking;