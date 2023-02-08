# Usage (conectamaria("firewall");)
sub conectamaria {
    use Config::File;
    my $cf = Config::File::read_config_file('../.env');
    $db="$_[0]";
    $connectionInfo="dbi:mysql:$db;$cf->{FW_MARIADB_HOST}";
    $dbh = DBI->connect($connectionInfo,$cf->{FW_MARIADB_USER},$cf->{FW_MARIADB_PASS}) or die "Unable to connect: $DBI::errstr\n";
    return $dbh;
}

sub getmplsbranches {
        use DBI;
        my $dbh2 = conectamaria("firewall");
        $sql_query="select abrev from oficinas where MPLS='SI'";
        my $result=$dbh2->prepare($sql_query);
        $result->execute();
        my $rows = $result->rows;
        my @branches;
        while ( my $row = $result->fetchrow_hashref()) {
            push @branches, $row->{abrev};
        }
        return @branches;
}

return 1;

