import { useEffect, useState } from 'react';
import { CartesianGrid, Legend, Line, LineChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import { getWeeklyStats } from '../services/statsService';

const StatisticsChart = () => {
  const [data, setData] = useState([]);
  useEffect(() => {
    const load = async () => {
      const result = await getWeeklyStats();
      setData(result);
    };
    load();
  }, []);

  return (
    <div className="panel-card chart-card">
      <div className="content-header">
        <h3 className="header-title">Statistics Overview</h3>
        <select className="filter-select">
          <option>This Week</option>
        </select>
      </div>
      <ResponsiveContainer width="100%" height={220}>
        <LineChart data={data}>
          <CartesianGrid stroke="#e2e8f0" strokeDasharray="3 3" />
          <XAxis dataKey="day" />
          <YAxis />
          <Tooltip />
          <Legend />
          <Line type="monotone" dataKey="Complaints" stroke="#3b82f6" strokeWidth={2} />
          <Line type="monotone" dataKey="Resolved" stroke="#22c55e" strokeWidth={2} />
          <Line type="monotone" dataKey="Pending" stroke="#ef4444" strokeWidth={2} />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
};

export default StatisticsChart;
