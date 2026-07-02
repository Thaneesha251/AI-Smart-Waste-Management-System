import { useEffect, useState } from 'react';
import { Cell, Pie, PieChart, ResponsiveContainer, Tooltip } from 'recharts';
import { getDistribution } from '../services/statsService';

const DistributionChart = () => {
  const [data, setData] = useState([]);

  useEffect(() => {
    const load = async () => {
      const result = await getDistribution();
      setData(result);
    };
    load();
  }, []);

  const total = data.reduce((sum, item) => sum + item.value, 0);

  return (
    <div className="panel-card chart-card">
      <div className="content-header">
        <h3 className="header-title">Waste Distribution</h3>
      </div>
      <div className="distribution-layout">
        <div className="distribution-chart-wrap">
          <ResponsiveContainer width="100%" height={220}>
            <PieChart>
              <Pie data={data} dataKey="value" innerRadius={50} outerRadius={75} paddingAngle={2}>
                {data.map((entry) => (
                  <Cell key={entry.name} fill={entry.color} />
                ))}
              </Pie>
              <Tooltip />
            </PieChart>
          </ResponsiveContainer>
          <div className="pie-center">
            <div className="pie-total">{total}</div>
            <div className="pie-label">Total</div>
          </div>
        </div>
        <div className="legend-list">
          {data.map((entry) => {
            const percent = total ? Math.round((entry.value / total) * 100) : 0;
            return (
              <div key={entry.name} className="legend-item">
                <span className="legend-dot" style={{ background: entry.color }} />
                <div className="legend-name">{entry.name}</div>
                <div className="legend-value">{entry.value} ({percent}%)</div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};

export default DistributionChart;
