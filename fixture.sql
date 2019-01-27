create extension pggraphblas;
select pg_backend_pid() pid \gset
\setenv PID :'pid'
\! tmux split-window -h
\! tmux send-keys 'gdb /usr/bin/postgres ' $PID  'C-m' 'cont' 'C-m'

create table edge (
    i bigint,
    j bigint,
    v bigint
    );

insert into edge (i, j, v) values 
    (1, 4, 1),
    (1, 2, 2),
    (2, 7, 3),
    (2, 5, 4),
    (3, 6, 5),
    (4, 3, 6),
    (4, 1, 7),
    (5, 6, 8),
    (6, 3, 9),
    (7, 3, 10);

create function test_m_ewise_mult() returns setof matrix_tuple as $$
    declare m matrix;
    begin
        select matrix_agg(i, j, v) from edge into m;
        return query select * from matrix_tuples(m && m);
    end;
$$ language plpgsql;
    
create function test_m_ewise_add() returns setof matrix_tuple as $$
    declare m matrix;
    begin
        select matrix_agg(i, j, v) from edge into m;
        return query select * from matrix_tuples(m || m);
    end;
$$ language plpgsql;


create function test_v_ewise_mult() returns setof vector_tuple as $$
    declare m vector;
    begin
        select vector_agg(i, v) from edge into m;
        return query select * from vector_tuples(m && m);
    end;
$$ language plpgsql;
    
create function test_v_ewise_add() returns setof vector_tuple as $$
    declare m vector;
    begin
        select vector_agg(i, v) from edge into m;
        return query select * from vector_tuples(m || m);
    end;
$$ language plpgsql;

create function matrix_from_table() returns matrix as $$
    declare m matrix;
    begin
        raise notice 'sql before agg';
        select matrix_agg(i, j, v) from edge into m;
        raise notice 'sql before return';
        return m || m;
    end;
$$ language plpgsql;

\prompt 'Crash it? (y/n)' store
\if :store        
select matrix_agg(i, j, v) from edge;
\endif
