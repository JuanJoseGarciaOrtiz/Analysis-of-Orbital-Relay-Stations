function v_f = PerformAttachment(m_station,m_payload,v_station,v_payload)
%Calculates final velocity of station + payload after succesfully attaching
%themselves
v_f = (m_station*v_station + m_payload*v_payload)/(m_station + m_payload);
end