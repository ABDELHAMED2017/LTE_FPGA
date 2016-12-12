classdef WARP
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        nodes
        node_tx
        node_rx
        rx_length
        tx_length
        ifc_ids
        eth_trig
    end
    
    methods
        function obj = WARP(N)
            USE_AGC                 = false;        % Use the AGC if running on WARP hardware
            obj.nodes = wl_initNodes(N);
            obj.node_tx = obj.nodes(1);
            obj.node_rx = obj.nodes(1);
            obj.eth_trig = wl_trigger_eth_udp_broadcast;
            wl_triggerManagerCmd(obj.nodes, 'add_ethernet_trigger', [obj.eth_trig]);
            trig_in_ids  = wl_getTriggerInputIDs(obj.nodes(1));
            trig_out_ids = wl_getTriggerOutputIDs(obj.nodes(1));
            wl_triggerManagerCmd(obj.nodes, 'output_config_input_selection', [trig_out_ids.BASEBAND], [trig_in_ids.ETH_A]);
            obj.ifc_ids = wl_getInterfaceIDs(obj.nodes(1));
            wl_interfaceCmd(obj.nodes, obj.ifc_ids.RF_ALL, 'channel', 2.4, 1);
            %wl_interfaceCmd(obj.nodes, obj.ifc_ids.RF_ALL, 'rx_lpf_corn_freq', 0);
            wl_interfaceCmd(obj.nodes, obj.ifc_ids.RF_ALL, 'rx_gain_mode', 'manual');
            wl_interfaceCmd(obj.nodes, obj.ifc_ids.RF_ALL, 'rx_gains', 2, 20);
            wl_interfaceCmd(obj.nodes, obj.ifc_ids.RF_ALL, 'tx_gains', 1, 8);
            
            if(USE_AGC)
                wl_interfaceCmd(obj.node_rx, obj.ifc_ids.RF_ALL, 'rx_gain_mode', 'automatic');
                wl_basebandCmd(obj.nodes, 'agc_target', -13);
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Set up the Baseband parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Get the baseband sampling frequencies from the board
            ts_tx   = 1 / (wl_basebandCmd(obj.nodes(1), 'tx_buff_clk_freq'));
            ts_rx   = 1 / (wl_basebandCmd(obj.nodes(1), 'rx_buff_clk_freq'));
            ts_rssi = 1 / (wl_basebandCmd(obj.nodes(1), 'rx_rssi_clk_freq'));
            maximum_buffer_len = wl_basebandCmd(obj.node_tx, obj.ifc_ids.RF_A, 'tx_buff_max_num_samples');
            
            % Set the transmission / receptions lengths (in samples)
            %     See WARPLab user guide for maximum length supported by WARP hardware
            %     versions and different WARPLab versions.
            tx_length        = 2^12;
            obj.rx_length    = tx_length;
            rssi_length  = obj.rx_length / (ts_rssi / ts_rx);
            
            % Check the transmission length
            if (tx_length > maximum_buffer_len)
                error('Node supports max transmission length of %d samples.  Requested %d samples.', maximum_buffer_len, tx_length);
            end
            
            % Set the length for the transmit and receive buffers based on the transmission length
            wl_basebandCmd(obj.nodes, 'tx_length', tx_length);
            wl_basebandCmd(obj.nodes, 'rx_length', obj.rx_length);
        end
        function rx_iq = broadcast(obj,tx_data)
            obj.tx_length = length(tx_data)+100;   %This would be more efficient elsewhere
            obj.rx_length    = obj.tx_length;
            wl_basebandCmd(obj.nodes, 'tx_length', obj.tx_length);
            wl_basebandCmd(obj.nodes, 'rx_length', obj.rx_length);
            
            wl_basebandCmd(obj.node_tx, [obj.ifc_ids.RF_A], 'write_IQ', tx_data);
            wl_interfaceCmd(obj.node_tx, obj.ifc_ids.RF_A, 'tx_en');
            wl_interfaceCmd(obj.node_rx, obj.ifc_ids.RF_B, 'rx_en');
            wl_basebandCmd(obj.node_tx, obj.ifc_ids.RF_A, 'tx_buff_en');
            wl_basebandCmd(obj.node_rx, obj.ifc_ids.RF_B, 'rx_buff_en');
            obj.eth_trig.send();
            rx_iq    = wl_basebandCmd(obj.node_rx, [obj.ifc_ids.RF_B], 'read_IQ', 0, obj.rx_length);
            %rx_rssi  = wl_basebandCmd(obj.node_rx, [obj.ifc_ids.RF_B], 'read_RSSI', 0, rssi_length);
            wl_basebandCmd(obj.nodes, obj.ifc_ids.RF_B, 'tx_rx_buff_dis');
            wl_interfaceCmd(obj.nodes, obj.ifc_ids.RF_B, 'tx_rx_dis');
            wl_basebandCmd(obj.nodes, obj.ifc_ids.RF_A, 'tx_rx_buff_dis');
            wl_interfaceCmd(obj.nodes, obj.ifc_ids.RF_A, 'tx_rx_dis');
            
            D = finddelay(tx_data,rx_iq);
            rx_iq = rx_iq(D+1:D+length(tx_data));
        end
    end
    
end

