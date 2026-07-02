import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { getRecentComplaints } from '../services/complaintsService';
import '../styles/RecentComplaint.css';

const RecentComplaints = () => {
  const navigate = useNavigate();
  const [complaints, setComplaints] = useState([]);
  const [activePage, setActivePage] = useState(1);

  useEffect(() => {
    const load = async () => {
      const data = await getRecentComplaints();
      setComplaints(data);
    };
    load();
  }, []);

  const getStatusClass = (status) => {
    if (status === 'Pending') return 'status-pending';
    if (status === 'In Progress') return 'status-inprogress';
    return 'status-resolved';
  };

  return (
    <div className="panel-card">
      <div className="content-header">
        <h3 className="header-title">Recent Complaints</h3>
        <button className="view-all-btn" onClick={() => navigate('/complaints')}>View All</button>
      </div>
      <table className="data-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Location</th>
            <th>Type</th>
            <th>Status</th>
            <th>Reported At</th>
          </tr>
        </thead>
        <tbody>
          {complaints.map((item) => (
            <tr key={item.id}>
              <td>{item.id}</td>
              <td>{item.location}</td>
              <td>{item.type} 🗑</td>
              <td><span className={`status-badge ${getStatusClass(item.status)}`}>{item.status}</span></td>
              <td>{item.time}</td>
            </tr>
          ))}
        </tbody>
      </table>
      <div className="pagination-row">
        <button onClick={() => setActivePage((p) => Math.max(1, p - 1))}>‹</button>
        <button className={activePage === 1 ? 'active' : ''} onClick={() => setActivePage(1)}>1</button>
        <button className={activePage === 2 ? 'active' : ''} onClick={() => setActivePage(2)}>2</button>
        <button className={activePage === 3 ? 'active' : ''} onClick={() => setActivePage(3)}>3</button>
        <button onClick={() => setActivePage((p) => p + 1)}>›</button>
      </div>
    </div>
  );
};

export default RecentComplaints;
