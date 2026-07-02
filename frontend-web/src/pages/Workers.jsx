import { useEffect, useState } from 'react';
import { CheckCircle2, Clock3, MapPin, Phone } from 'lucide-react';
import { getWorkers } from '../services/workersService';

const Workers = () => {
  const [workers, setWorkers] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const load = async () => {
      setLoading(true);
      const data = await getWorkers();
      setWorkers(data);
      setLoading(false);
    };
    load();
  }, []);

  const getStatusClass = (status) => {
    if (status === 'On Duty') return 'status-resolved';
    if (status === 'On Leave') return 'status-pending';
    return 'status-inprogress';
  };

  return (
    <div className="content-wrapper">
      <div className="content-header">
        <div>
          <h2 className="header-title">Workers</h2>
          <p className="header-subtitle">Manage field team availability and performance.</p>
        </div>
        <button className="primary-btn">Add Worker</button>
      </div>
      {loading ? <div className="empty-state">Loading workers...</div> : (
        <div className="workers-grid">
          {workers.map((worker) => (
            <div key={worker.id} className="worker-card">
              <div className="worker-header">
                <div className="worker-avatar">{worker.name.slice(0, 2).toUpperCase()}</div>
                <div>
                  <h3>{worker.name}</h3>
                  <div className="muted-text">{worker.zone}</div>
                </div>
              </div>
              <div className="worker-meta"><Phone size={14} /> {worker.phone}</div>
              <div className="worker-meta"><MapPin size={14} /> {worker.zone}</div>
              <div className="worker-status-row">
                <span className={`status-badge ${getStatusClass(worker.status)}`}>{worker.status}</span>
              </div>
              <div className="worker-stats">
                <div><CheckCircle2 size={16} /> {worker.completed} completed</div>
                <div><Clock3 size={16} /> {worker.tasks} pending</div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default Workers;
