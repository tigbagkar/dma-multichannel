interface user_irq_if;
    import global_pkg :: NUM_CH;

    logic [NUM_CH-1:0] irq;
    
    modport source (
        output irq
    );
    
    modport consumer (
        input irq
    );
endinterface
